library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity safe_logic is
    port (
        clk            : in  std_logic;
        data_valid     : in  std_logic;                    
        data_in        : in  std_logic_vector(7 downto 0);         
        o_tx_start     : out std_logic;
        o_tx_byte      : out std_logic_vector(7 downto 0);
        o_locked       : out std_logic;  
        o_unlocked     : out std_logic;  
        o_is_penalty   : out std_logic   
    );
end entity;

architecture rtl of safe_logic is
    type state_type is (s_LOCKED, s_CHECK1, s_CHECK2, s_UNLOCKED, s_PENALTY);
    signal current_state : state_type := s_LOCKED;
    signal fail_counter  : integer range 0 to 3 := 0;
    signal timer_reg     : unsigned(31 downto 0) := (others => '0');
    constant PENALTY_LIMIT : unsigned(31 downto 0) := to_unsigned(1500000000, 32);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            o_tx_start <= '0';

            case current_state is
                when s_LOCKED =>
                    o_locked <= '1'; o_unlocked <= '0'; o_is_penalty <= '0';
                    if data_valid = '1' then
                        if data_in = x"31" then 
                            current_state <= s_CHECK1;
                        else
                            fail_counter <= fail_counter + 1;
                            if fail_counter >= 2 then
                                current_state <= s_PENALTY;
                            end if;
                        end if;
                    end if;

                when s_UNLOCKED =>
                    o_locked <= '0'; o_unlocked <= '1'; o_is_penalty <= '0';

                when s_PENALTY =>
                    o_locked <= '1'; o_unlocked <= '0'; o_is_penalty <= '1';
                    if timer_reg < PENALTY_LIMIT then
                        timer_reg <= timer_reg + 1;
                    else
                        timer_reg <= (others => '0');
                        fail_counter <= 0;
                        current_state <= s_LOCKED;
                    end if;

                when others => current_state <= s_LOCKED;
            end case;
        end if;
    end process;
end architecture;
