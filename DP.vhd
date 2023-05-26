library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions


entity DP is
	port (	
			reset, clk : IN std_logic;
			theta 	: IN std_logic_vector(15 downto 0);

			Init_X, Load_X : IN std_logic ;
			Init_Y, Load_Y : IN std_logic ;
			Init_Z, Load_Z : IN std_logic ;
			Init_c, Load_c : IN std_logic ;
	
			CZ     : OUT std_logic := '0';
			cos, sin : OUT std_logic_vector(15 downto 0)
	);
end DP;

architecture DP_arc of DP is

-- LUT (I guess c le bon terme)
type my_array is array (0 to 10) of std_logic_vector(15 downto 0);

signal tab : my_array := (
	0  => "0011001001000011", -- pi/4   7853
	1  => "0001110110101010", 
	2  => "0000111110101011", 
	3  => "0000011111110101", 
	4  => "0000001111111100",
	5  => "0000000111111111",
	6  => "0000000011111110",
	7  => "0000000000101010", 
	8  => "0000000000111111", 
	9  => "0000000000100000", 
	10 => "0000000000010000"
	);



signal x : std_logic_vector (15 downto 0) := "0100000000000000";
signal y : std_logic_vector (15 downto 0) := (others => '0');

signal tan_X, tan_Y : std_logic_vector (15 downto 0);

signal k : integer range 0 to 9;

signal msb : std_logic; --1ere iteration +45°

component Barrel_shifter is
port(
	x: In std_logic_vector(15 downto 0);
	s:In integer range 0 to 9;
	W:Out std_logic_vector(15 downto 0));
end component;


begin

	-- Ce code travaille dans l'intervalle [-pi/2, pi/2]

	cos <= x when theta(15) = '0' else y;
	sin <= y when theta(15) = '0' else x;


	-- Registre x
	process (clk)
	variable xx : std_logic_vector (15 downto 0);
	
	begin
		if rising_edge(clk) then
			if reset = '1' then	
				xx := (others => '0');
			elsif Init_X = '1' then
				xx := "0100000000000000"; -- 1
			elsif Load_X = '1' then
				if msb = '1' then
					xx := xx + tan_Y;
				else 
					xx := xx - tan_Y;
				end if;

				xx := xx;
			else
				xx := xx;
			end if;

			x <= xx;
		end if;

	end process;


	-- Registre y
	process (clk)
	variable yy : std_logic_vector (15 downto 0);
	
	begin
		if rising_edge(clk) then
			if reset = '1' then	
				yy := (others => '0');
			elsif Init_Y = '1' then
				yy := (others => '0'); 
			elsif Load_Y = '1' then
				if msb = '1' then
					yy := yy - tan_X;
				else 
					yy := yy + tan_X;
				end if;

				yy := yy;

			else
				yy := yy;
			end if;

			y <= yy;
		end if;

	end process;



	-- Barrel Shifter x
	Mult_X : Barrel_shifter port map(x, k, tan_X);

	-- Barrel Shifter y
	Mult_Y : Barrel_shifter port map(y, k, tan_Y);





	-- Registre Compteur
	process (clk)
	variable kk : integer range 0 to 9;
	
	begin
		if rising_edge(clk) then
			if reset = '1' then	
				kk := 0;

			elsif Init_x = '1' then
				kk := 0; 

			elsif Load_c = '1' then
				if kk = 8 then
					CZ <= '1';
				elsif kk = 9 then
					kk := 0;
				else
					kk := kk + 1;
				end if;				
		end if;

		k <= kk;
	end if;
end process;

	-- Registre Z
	process (clk)
	variable zz : std_logic_vector(15 downto 0);
	variable msbb : std_logic_vector(15 downto 0);
	
	begin
		if rising_edge(clk) then
			if reset = '1' then	
				zz := (others => '0');

			elsif Init_Z = '1' then
				if theta(15) = '0' then
					zz := tab(0); --pi/4
				else --aka: negatif
					zz := "1100110110111100";  -- -pi/4
				end if;
				
			elsif Load_Z = '1' then
				msbb := theta - zz; -- sens de rotation
				
				if (msbb(15) = '1') then
					zz := zz - tab(k+1);
				else
					zz :=  zz + tab(k+1);
				end if;

			else
				zz := zz;

			end if;

		msb <= msbb(15);
	end if;

	end process;



end DP_arc;