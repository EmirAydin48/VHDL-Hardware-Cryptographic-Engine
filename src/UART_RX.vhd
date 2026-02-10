library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX is
    Generic (
        CLKS_PER_BIT : integer := 10416
    );
    Port (
        i_Clk       : in  STD_LOGIC;
        i_RX_Serial : in  STD_LOGIC;
        o_RX_DV     : out STD_LOGIC;
        o_RX_Byte   : out STD_LOGIC_VECTOR (7 downto 0)
    );
end UART_RX;

architecture Behavioral of UART_RX is
    type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits, s_RX_Stop_Bit, s_Cleanup);
    signal r_SM_Main : t_SM_Main := s_Idle;
    
    signal r_Clk_Count : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal r_Bit_Index : integer range 0 to 7 := 0;
    signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
    signal r_RX_Data_R : std_logic := '1';
    signal r_RX_Data   : std_logic := '1';
    
begin
    p_SAMPLE : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            r_RX_Data_R <= i_RX_Serial;
            r_RX_Data   <= r_RX_Data_R;
        end if;
    end process p_SAMPLE;

    p_UART_RX : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            case r_SM_Main is
                when s_Idle =>
                    o_RX_DV <= '0';
                    r_Clk_Count <= 0;
                    r_Bit_Index <= 0;
                    if r_RX_Data = '0' then
                        r_SM_Main <= s_RX_Start_Bit;
                    else
                        r_SM_Main <= s_Idle;
                    end if;

                when s_RX_Start_Bit =>
                    if r_Clk_Count = (CLKS_PER_BIT-1)/2 then
                        if r_RX_Data = '0' then
                            r_Clk_Count <= 0;
                            r_SM_Main   <= s_RX_Data_Bits;
                        else
                            r_SM_Main   <= s_Idle;
                        end if;
                    else
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_RX_Start_Bit;
                    end if;

                when s_RX_Data_Bits =>
                    if r_Clk_Count < CLKS_PER_BIT-1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_RX_Data_Bits;
                    else
                        r_Clk_Count            <= 0;
                        r_RX_Byte(r_Bit_Index) <= r_RX_Data;
                        
                        if r_Bit_Index < 7 then
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_SM_Main   <= s_RX_Data_Bits;
                        else
                            r_Bit_Index <= 0;
                            r_SM_Main   <= s_RX_Stop_Bit;
                        end if;
                    end if;

                when s_RX_Stop_Bit =>
                    if r_Clk_Count < CLKS_PER_BIT-1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_RX_Stop_Bit;
                    else
                        o_RX_DV     <= '1';
                        o_RX_Byte   <= r_RX_Byte;
                        r_Clk_Count <= 0;
                        r_SM_Main   <= s_Cleanup;
                    end if;

                when s_Cleanup =>
                    r_SM_Main <= s_Idle;
                    o_RX_DV   <= '0';

                when others =>
                    r_SM_Main <= s_Idle;
            end case;
        end if;
    end process p_UART_RX;
end Behavioral;