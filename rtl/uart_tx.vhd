library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    port (
        clk       : in  std_logic;
        tx_start  : in  std_logic;
        data_in   : in  std_logic_vector(7 downto 0);
        tx_line   : out std_logic
    );
end entity;

architecture rtl of uart_tx is
    constant CLKS_PER_BIT : integer := 5208; -- 50MHz / 9600 baud
    type state_type is (s_IDLE, s_START, s_DATA, s_STOP);
    signal state : state_type := s_IDLE;
    signal clk_cnt : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_idx : integer range 0 to 7 := 0;
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when s_IDLE =>
                    tx_line <= '1';
                    if tx_start = '1' then
                        data_reg <= data_in;
                        state <= s_START;
                    end if;
                when s_START =>
                    tx_line <= '0';
                    if clk_cnt < CLKS_PER_BIT-1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        state <= s_DATA;
                    end if;
                when s_DATA =>
                    tx_line <= data_reg(bit_idx);
                    if clk_cnt < CLKS_PER_BIT-1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        if bit_idx < 7 then
                            bit_idx <= bit_idx + 1;
                        else
                            bit_idx <= 0;
                            state <= s_STOP;
                        end if;
                    end if;
                when s_STOP =>
                    tx_line <= '1';
                    if clk_cnt < CLKS_PER_BIT-1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        state <= s_IDLE;
                    end if;
            end case;
        end if;
    end process;
end architecture;
