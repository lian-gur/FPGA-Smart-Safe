library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port (
        clk        : in  std_logic;                     
        rx_line    : in  std_logic;                     
        data_out   : out std_logic_vector(7 downto 0);
        data_valid : out std_logic
    );
end entity;

architecture rtl of uart_rx is
    constant CLKS_PER_BIT : integer := 5208; -- 50MHz / 9600 baud
    type state_type is (s_IDLE, s_START, s_DATA, s_STOP);
    signal state     : state_type := s_IDLE;
    signal clk_cnt   : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_idx   : integer range 0 to 7 := 0;
    signal data_reg  : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk) 
    begin
        if rising_edge(clk) then 
            case state is
                when s_IDLE =>
                    data_valid <= '0';
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if rx_line = '0' then 
                        state <= s_START;
                    end if;

                when s_START =>
                    if clk_cnt = (CLKS_PER_BIT-1)/2 then 
                        if rx_line = '0' then
                            clk_cnt <= 0;
                            state <= s_DATA;
                        else
                            state <= s_IDLE;
                        end if;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;

                when s_DATA =>
                    if clk_cnt < CLKS_PER_BIT-1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        data_reg(bit_idx) <= rx_line;
                        if bit_idx < 7 then
                            bit_idx <= bit_idx + 1;
                        else
                            bit_idx <= 0;
                            state <= s_STOP;
                        end if;
                    end if;

                when s_STOP =>
                    if clk_cnt < CLKS_PER_BIT-1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        data_out <= data_reg;
                        data_valid <= '1';
                        clk_cnt <= 0;
                        state <= s_IDLE;
                    end if;
            end case;
        end if;
    end process;
end architecture;
