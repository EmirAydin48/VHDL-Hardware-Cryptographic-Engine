library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity Encrypt is
    Port (
        CLK             : in STD_LOGIC;
        RESET           : in STD_LOGIC;
        KB_INPUT        : in std_logic_vector (6 downto 0);
        ENCRYPTED_OUT   : out std_logic_vector (6 downto 0);
        SEG_DISPLAY     : out std_logic_vector (6 downto 0)
        );
end Encrypt;

architecture Behavioral of Encrypt is
    signal key_generator: STD_LOGIC_VECTOR (6 downto 0) := "1010101";
    signal keys         : STD_LOGIC_VECTOR (6 downto 0);

    signal anchor       : std_logic_vector (2 downto 0);
    signal target       : std_logic_vector (3 downto 0);
    signal mixer_out    : std_logic_vector (6 downto 0);
    signal final_cipher : std_logic_vector (6 downto 0);
begin
    anchor <= KB_INPUT(6 downto 4);
    target <= KB_INPUT(3 downto 0);
    
    process(CLK, RESET)
    begin
        if RESET = '1' then key_generator <= "1010101";
        elsif rising_edge(CLK) then
        key_generator(0) <= NOT (key_generator(3) xor key_generator(6));
        key_generator(6 downto 1) <= key_generator(5 downto 0);
        end if;
    end process;
    
    keys(0) <= key_generator(0);
    keys(1) <= key_generator(1);
    keys(2) <= key_generator(2);
    keys(3) <= key_generator(3);
    keys(4) <= key_generator(4);
    keys(5) <= key_generator(5);
    keys(6) <= key_generator(6);
    
    process(anchor, target)
    begin
        mixer_out(6 downto 4) <= anchor;
        mixer_out(3 downto 0) <= target XOR (anchor & '0');
    end process;
    
    final_cipher(0) <= mixer_out(0) xor keys(0);
    final_cipher(1) <= mixer_out(1) xor keys(3);
    final_cipher(2) <= mixer_out(2) xor keys(1);
    final_cipher(3) <= mixer_out(3) xor keys(5);
    final_cipher(4) <= mixer_out(4) xor keys(0);
    final_cipher(5) <= mixer_out(5) xor keys(6);
    final_cipher(6) <= mixer_out(6) xor keys(2);
    
    ENCRYPTED_OUT <= final_cipher;
    
    process(clk)
    begin
        case final_cipher(3 downto 0) is
            when "0000" => SEG_DISPLAY <= "1000000";
            when "0001" => SEG_DISPLAY <= "1111001";
            when "0010" => SEG_DISPLAY <= "0100100";
            when "0011" => SEG_DISPLAY <= "0110000";
            when "0100" => SEG_DISPLAY <= "0011001";
            when "0101" => SEG_DISPLAY <= "0010010";
            when "0111" => SEG_DISPLAY <= "0000010";
            when "1000" => SEG_DISPLAY <= "1111000";
            when "1001" => SEG_DISPLAY <= "0010000";
            
            -- Hex A to F
            when "1010" => SEG_DISPLAY <= "0001000";
            when "1011" => SEG_DISPLAY <= "0000011";
            when "1100" => SEG_DISPLAY <= "1000110";
            when "1101" => SEG_DISPLAY <= "0100001";
            when "1110" => SEG_DISPLAY <= "0000110";
            when "1111" => SEG_DISPLAY <= "0001110";
            
            when others => SEG_DISPLAY <= "1111111";
            end case;
    end process;
end Behavioral;
