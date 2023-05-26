library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Decodeur_bcd_7Seg is
port (data : in std_logic_vector (3 downto 0);
		C : out std_logic_vector(7 downto 0));
end Decodeur_bcd_7Seg;

architecture Behavioral of Decodeur_bcd_7Seg is

begin
with Data select C <=
"01000000" when "X000",  -- cos pas la peine de prendre le cas >1
"11000000" when x"0",
"11111001" when x"1",
"10100100" when x"2",
"10110000" when x"3",
"10011001" when x"4",
"10010010" when x"5",
"10000010" when x"6",
"11111000" when x"7",
"10000000" when x"8",
"10010000" when x"9",
"10111111" when others;

end Behavioral;



-- Quand reçoit "X00"&partie_entiere affiche avec point 
