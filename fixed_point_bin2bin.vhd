library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions


entity bin2fixed_point_bin is
	port (												    --	  +1.3301
		bin_fixed_point : IN std_logic_vector(15 downto 0); --    01.01010100100001 || 21793  pour la division /2^14
							--									     50000000000000
							--									     25000000000000
							--									     12500000000000
							--									     06250000000000
							--									   0.00006103515625 2^-14
							--									  0101010100100001


		bin_treated_frac    : OUT std_logic_vector(13 downto 0);    -- *0.607*2^-14 if positif
		bin_treated_integer : OUT std_logic;    
		signe : OUT std_logic
	);
end bin2fixed_point_bin;


-- 50MHz   NEXYS2 || 100MHz NEXYS4


--pour multiplier A*0.607  => A(2^-1 + 2^-4 + 2^-5 + 2^-7 + 2^-8 + 2^-10 + 2^-11 + 2^-14)     00 10011011011001

architecture bin2fixed_point_bin_arc of bin2fixed_point_bin is

component Barrel_shifter_14 is
port(
	x : In std_logic_vector(15 downto 0);
	s : In integer range 0 to 14;
	W : Out std_logic_vector(15 downto 0));
end component;


type my_array is array (13 downto 0) of integer range 0 to 5000;

signal Kn_result: std_logic_vector(15 downto 0);  --aka: Kn * result 

signal A, B, C, D, E, F, G, H : std_logic_vector(15 downto 0);  


signal Decod_Positif : my_array := (
	0 => 5000,
	1 => 2500,
	2 => 1250,
	3 => 625,
	4 => 312,
	5 => 156,
	6 => 78,
	7 => 39,
	8 => 19,
	9 =>  9,
	10 => 4,
	11 => 2,
	12 => 1,
	13 => 0
	);


begin


	-- 	On multiplie par 0.607	

	shift1 : Barrel_shifter_14 port map(bin_fixed_point, 1,  A);
	shift2 : Barrel_shifter_14 port map(bin_fixed_point, 4,  B);
	shift3 : Barrel_shifter_14 port map(bin_fixed_point, 5,  C);
	shift4 : Barrel_shifter_14 port map(bin_fixed_point, 7,  D);
	shift5 : Barrel_shifter_14 port map(bin_fixed_point, 8,  E);
	shift6 : Barrel_shifter_14 port map(bin_fixed_point, 10, F);
	shift7 : Barrel_shifter_14 port map(bin_fixed_point, 11, G);
	shift8 : Barrel_shifter_14 port map(bin_fixed_point, 14, H);

	Kn_result <= A + B + C + D + E + F + G + H; -- c bon on a bin multiplié par 0.607



	-- Signe
	signe <= bin_fixed_point(15);

	-- Partie Entière
	bin_treated_integer <= Kn_result(15);




	-- Maintenant On decode la partie fractionnaire !

	-- if positif ===>  *2^14
	process (Kn_result)
	variable a : integer range 0 to 10000 := 0;
	begin

		for i in 0 to 13 loop
			if Kn_result(13-i) = '1' then
				a := a + Decod_Positif(i);
			end if;
		end loop;

		bin_treated_frac <= std_logic_vector(to_unsigned(a, bin_treated_frac'length));  
		a := 0; 
	end process ;







end bin2fixed_point_bin_arc;