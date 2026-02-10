library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX is
    Generic (
        CLKS_PER_BIT : integer := 10416
    );
    Port (
        i_Clk       : in  STD_LOGIC;
        i_TX_DV     : in  STD_LOGIC;
        i_TX_Byte   : in  STD_LOGIC_VECTOR(7 downto 0);
        o_TX_Active : out STD_LOGIC;
        o_TX_Serial : out STD_LOGIC;
        o_TX_Done   : out STD_LOGIC
    );
end UART_TX;

architecture Behavioral of UART_TX is
    type t_SM_Main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits, s_TX_Stop_Bit, s_Cleanup);
    signal r_SM_Main : t_SM_Main := s_Idle;
    
    signal r_Clk_Count : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal r_Bit_Index : integer range 0 to 7 := 0;
    signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
    
begin
    p_UART_TX : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            case r_SM_Main is
                when s_Idle =>
                    o_TX_Active <= '0';
                    o_TX_Serial <= '1';
                    o_TX_Done   <= '0';
                    r_Clk_Count <= 0;
                    r_Bit_Index <= 0;
                    
                    if i_TX_DV = '1' then
                        r_TX_Data <= i_TX_Byte;
                        r_SM_Main <= s_TX_Start_Bit;
                    else
                        r_SM_Main <= s_Idle;
                    end if;

                when s_TX_Start_Bit =>
                    o_TX_Active <= '1';
                    o_TX_Serial <= '0';
                    
                    if r_Clk_Count < CLKS_PER_BIT-1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_TX_Start_Bit;
                    else
                        r_Clk_Count <= 0;
                        r_SM_Main   <= s_TX_Data_Bits;
                    end if;

                when s_TX_Data_Bits =>
                    o_TX_Serial <= r_TX_Data(r_Bit_Index);
                    
                    if r_Clk_Count < CLKS_PER_BIT-1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_TX_Data_Bits;
                    else
                        r_Clk_Count <= 0;
                        if r_Bit_Index < 7 then
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_SM_Main   <= s_TX_Data_Bits;
                        else
                            r_Bit_Index <= 0;
                            r_SM_Main   <= s_TX_Stop_Bit;
                        end if;
                    end if;

                when s_TX_Stop_Bit =>
                    o_TX_Serial <= '1';
                    
                    if r_Clk_Count < CLKS_PER_BIT-1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_TX_Stop_Bit;
                    else
                        o_TX_Done   <= '1';
                        r_Clk_Count <= 0;
                        r_SM_Main   <= s_Cleanup;
                    end if;

                when s_Cleanup =>
                    o_TX_Active <= '0';
                    o_TX_Done   <= '1';
                    r_SM_Main   <= s_Idle;
                    
                when others =>
                    r_SM_Main <= s_Idle;
            end case;
        end if;
    end process p_UART_TX;
end Behavioral;