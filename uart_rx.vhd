library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (
        g_CLKS_PER_BIT : integer := 5208     -- 50MHz / 9600 baud
    );
    port (
        i_clk       : in  std_logic;         -- ???? ??????
        i_rx_serial : in  std_logic;         -- ??? ???? ?????
        o_rx_dv     : out std_logic;         -- '1' ???? ?? ??? ????
        o_rx_byte   : out std_logic_vector(7 downto 0) -- ??? ?????
    );
end uart_rx;

architecture rtl of uart_rx is
    -- ????? ?????? ?? ??????
    type t_sm_state is (s_IDLE, s_RX_START_BIT, s_RX_DATA_BITS, 
                         s_RX_STOP_BIT, s_CLEANUP);
    signal r_sm_state : t_sm_state := s_IDLE;
    
    signal r_clk_count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
    signal r_bit_index : integer range 0 to 7 := 0; -- ???? 8 ?????
    signal r_rx_byte   : std_logic_vector(7 downto 0) := (others => '0');
    signal r_rx_dv     : std_logic := '0';
begin

    -- ????? ????? ???????
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            case r_sm_state is
                when s_IDLE =>
                    r_rx_dv     <= '0';
                    r_clk_count <= 0;
                    r_bit_index <= 0;
                    
                    if i_rx_serial = '0' then -- ????? Start Bit (????? ?-0)
                        r_sm_state <= s_RX_START_BIT;
                    else
                        r_sm_state <= s_IDLE;
                    end if;

                when s_RX_START_BIT =>
                    -- ????? ????? ???? ?????? ??? ????? ??? ?? ???
                    if r_clk_count = (g_CLKS_PER_BIT-1)/2 then
                        if i_rx_serial = '0' then
                            r_clk_count <= 0;
                            r_sm_state   <= s_RX_DATA_BITS;
                        else
                            r_sm_state   <= s_IDLE;
                        end if;
                    else
                        r_clk_count <= r_clk_count + 1;
                    end if;

                -- ??? ????? ??? ?????? (Data, Stop) ???? ???...
                when others =>
                    r_sm_state <= s_IDLE;
            end case;
        end if;
    end process;

    o_rx_dv   <= r_rx_dv;
    o_rx_byte <= r_rx_byte;
    
end rtl;