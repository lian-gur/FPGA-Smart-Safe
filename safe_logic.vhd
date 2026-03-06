library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity safe_logic is
    port (
        i_clk           : in  std_logic;
        i_rx_dv         : in  std_logic;                     
        i_rx_byte       : in  std_logic_vector(7 downto 0);  
        o_locked        : out std_logic;                     
        o_unlocked      : out std_logic                      
    );
end safe_logic;

architecture rtl of safe_logic is
    type t_sm_state is (s_LOCKED, s_CHECK_BYTE, s_UNLOCKED);
    signal r_sm_state : t_sm_state := s_LOCKED;

    -- '1' = x31, '2' = x32, '3' = x33, '4' = x34
    constant c_PASS_1 : std_logic_vector(7 downto 0) := x"31";
    constant c_PASS_2 : std_logic_vector(7 downto 0) := x"32";
    constant c_PASS_3 : std_logic_vector(7 downto 0) := x"33";
    constant c_PASS_4 : std_logic_vector(7 downto 0) := x"34";

    signal r_digit_count : integer range 1 to 4 := 1;

begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            case r_sm_state is
                
                when s_LOCKED =>
                    o_locked   <= '1';
                    o_unlocked <= '0';
                    if i_rx_dv = '1' then  
                        r_sm_state <= s_CHECK_BYTE;
                    end if;

                when s_CHECK_BYTE =>
                    if (r_digit_count = 1 and i_rx_byte = c_PASS_1) or
                       (r_digit_count = 2 and i_rx_byte = c_PASS_2) or
                       (r_digit_count = 3 and i_rx_byte = c_PASS_3) or
                       (r_digit_count = 4 and i_rx_byte = c_PASS_4) then
                        
                        if r_digit_count = 4 then
                            r_sm_state <= s_UNLOCKED; 
                        else
                            r_digit_count <= r_digit_count + 1;
                            r_sm_state    <= s_LOCKED;
                        end if;
                    else
                        r_digit_count <= 1;
                        r_sm_state    <= s_LOCKED;
                    end if;

                when s_UNLOCKED =>
                    o_locked   <= '0';
                    o_unlocked <= '1';
                
                when others =>
                    r_sm_state <= s_LOCKED;
            end case;
        end if;
    end process;


end rtl;
