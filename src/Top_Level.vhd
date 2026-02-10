library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_Level_System is
    Port (
        CLK         : in STD_LOGIC;
        RsRx        : in STD_LOGIC;
        RsTx        : out STD_LOGIC;
        led         : out STD_LOGIC_VECTOR(15 downto 0);
        seg         : out STD_LOGIC_VECTOR(6 downto 0);
        an          : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Top_Level_System;

architecture Behavioral of Top_Level_System is

    signal w_RX_Byte   : std_logic_vector(7 downto 0);
    signal w_RX_DV     : std_logic;
    
    signal r_LFSR      : std_logic_vector(6 downto 0) := "1010101";
    signal w_Keys      : std_logic_vector(6 downto 0);
    signal w_Anchor    : std_logic_vector(2 downto 0);
    signal w_Target    : std_logic_vector(3 downto 0);
    signal w_Feistel   : std_logic_vector(6 downto 0);
    signal w_Cipher    : std_logic_vector(6 downto 0);
    
    signal w_Hex_Digit : std_logic_vector(3 downto 0);
    signal r_Digit_Sel : std_logic_vector(1 downto 0) := "00";
    signal r_Refresh   : integer range 0 to 200000 := 0;

    component UART_RX is
        Port ( i_Clk : in STD_LOGIC; i_RX_Serial : in STD_LOGIC;
               o_RX_DV : out STD_LOGIC; o_RX_Byte : out STD_LOGIC_VECTOR(7 downto 0));
    end component;

    component UART_TX is
        Port ( i_Clk : in STD_LOGIC; i_TX_DV : in STD_LOGIC;
               i_TX_Byte : in STD_LOGIC_VECTOR(7 downto 0);
               o_TX_Active : out STD_LOGIC; o_TX_Serial : out STD_LOGIC; o_TX_Done : out STD_LOGIC);
    end component;

begin

    UART_RX_Inst : UART_RX
    port map (
        i_Clk       => CLK,
        i_RX_Serial => RsRx,
        o_RX_DV     => w_RX_DV,
        o_RX_Byte   => w_RX_Byte
    );

    UART_TX_Inst : UART_TX
    port map (
        i_Clk       => CLK,
        i_TX_DV     => w_RX_DV,
        i_TX_Byte   => w_RX_Byte,
        o_TX_Active => open,
        o_TX_Serial => RsTx,
        o_TX_Done   => open
    );

    process(CLK)
    begin
        if rising_edge(CLK) then
            if w_RX_DV = '1' then
                r_LFSR(0) <= NOT (r_LFSR(3) XOR r_LFSR(6));
                r_LFSR(6 downto 1) <= r_LFSR(5 downto 0);
            end if;
        end if;
    end process;
    w_Keys <= r_LFSR;

    w_Anchor <= w_RX_Byte(2 downto 0);
    w_Target <= w_RX_Byte(6 downto 3);
    
    w_Feistel(2 downto 0) <= w_Anchor;
    w_Feistel(6 downto 3) <= w_Target XOR ('0' & w_Anchor);
    
    w_Cipher <= w_Feistel XOR w_Keys;

    led(6 downto 0) <= w_Cipher;
    led(15 downto 7) <= (others => '0');

    process(CLK)
    begin
        if rising_edge(CLK) then
            r_Refresh <= r_Refresh + 1;
            if r_Refresh = 0 then
                r_Digit_Sel <= std_logic_vector(unsigned(r_Digit_Sel) + 1);
            end if;
        end if;
    end process;
    
    process(r_Digit_Sel, w_Cipher)
    begin
        case r_Digit_Sel is
            when "00" => 
                an <= "1110"; 
                w_Hex_Digit <= '0' & w_Cipher(2 downto 0);
            when "01" => 
                an <= "1101";
                w_Hex_Digit <= w_Cipher(6 downto 3);
            when others =>
                an <= "1111"; 
                w_Hex_Digit <= "0000";
        end case;
    end process;

    process(w_Hex_Digit)
    begin
        case w_Hex_Digit is
            when "0000" => seg <= "1000000";
            when "0001" => seg <= "1111001";
            when "0010" => seg <= "0100100";
            when "0011" => seg <= "0110000";
            when "0100" => seg <= "0011001";
            when "0101" => seg <= "0010010";
            when "0110" => seg <= "0000010";
            when "0111" => seg <= "1111000";
            when "1000" => seg <= "0000000";
            when "1001" => seg <= "0010000";
            when "1010" => seg <= "0001000";
            when "1011" => seg <= "0000011";
            when "1100" => seg <= "1000110";
            when "1101" => seg <= "0100001";
            when "1110" => seg <= "0000110";
            when "1111" => seg <= "0001110";
            when others => seg <= "1111111";
        end case;
    end process;

end Behavioral;