Library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_std.all;
use ieee.std_logic_signed.all;


entity Barrel_shifter_14 is
port(
	x : In std_logic_vector(15 downto 0);
	s : In integer range 0 to 14;
	W : Out std_logic_vector(15 downto 0));
end entity;


architecture DF OF Barrel_shifter_14 is
signal s1 : std_logic_vector(3 downto 0);

begin
	s1 <= std_logic_vector(to_unsigned(s,4));
	W <= shr(x, s1);

end architecture;