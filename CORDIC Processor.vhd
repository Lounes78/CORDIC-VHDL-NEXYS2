library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions


entity Tooop is
	port (
		clk, reset, Go, Choix :  IN std_logic;
--		theta : IN std_logic_vector(15 downto 0);
		Choix_theta : IN std_logic_vector(2 downto 0);


        Anode_Activate : OUT STD_LOGIC_VECTOR (3 downto 0);

		signe_cos, signe_sin_bric : OUT std_logic; --vers une LED;

		S_7seg : out std_logic_vector(7 downto 0)
	);
end Tooop;




architecture Tooop_arc of Tooop is

signal theta : std_logic_vector(15 downto 0);


component DP is
	port (	
			reset, clk : IN std_logic;
			theta 	: IN std_logic_vector(15 downto 0);

			Init_X, Load_X : IN std_logic;
			Init_Y, Load_Y : IN std_logic;
			Init_Z, Load_Z : IN std_logic;
			Init_c, Load_c : IN std_logic;
	
			CZ     : OUT std_logic;
			cos, sin : OUT std_logic_vector(15 downto 0)
	);
end component;




component CU is
	port (
			reset, clk, Go, CZ  : IN std_logic;

			Init_X, Load_X : OUT std_logic;
			Init_Y, Load_Y : OUT std_logic;
			Init_Z, Load_Z : OUT std_logic; -- Sens de Rotation
			Init_c, Load_c : OUT std_logic -- Nombre d'itérations
		
	);
end component;


-- Conversion point fixe complement à 2 vers LISIBLE

component bin2fixed_point_bin is
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
end component;


--  ------- Affichage 7 segments -------

component binary_bcd is
    generic(N: positive := 16);
    port(
        clk, reset: in std_logic;
        binary_in: in std_logic_vector(N-1 downto 0);
        bcd0, bcd1, bcd2, bcd3, bcd4: out std_logic_vector(3 downto 0)
    );
end component ;


component seven_segment_ctrl is
    Port ( clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           bcd0, bcd1, bcd2, bcd3 : IN STD_LOGIC_VECTOR (3 downto 0);

           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);
           LED_BCD        : out STD_LOGIC_VECTOR (3 downto 0)  -- 
           );
end component;



component Decodeur_bcd_7Seg is
port ( data : in std_logic_vector (3 downto 0);
		C : out std_logic_vector(7 downto 0));
end component;




-- SIGNAUX 

signal Init_X, Load_X : std_logic;
signal Init_Y, Load_Y : std_logic;
signal Init_Z, Load_Z : std_logic;
signal Init_c, Load_c : std_logic;
	
signal CZ : std_logic;

signal cos, sin : std_logic_vector(15 downto 0);


signal bin_treated_frac_cos_bis, bin_treated_frac_sin_bis : std_logic_vector(15 downto 0);
	
signal bin_treated_frac_cos, bin_treated_frac_sin : std_logic_vector(13 downto 0);    -- *0.607*2^-14 if positif

signal bin_treated_integer_cos, bin_treated_integer_sin : std_logic;

signal bcd0_cos, bcd1_cos, bcd2_cos, bcd3_cos, bcd4_cos : std_logic_vector(3 downto 0);

signal bcd0_sin, bcd1_sin, bcd2_sin, bcd3_sin, bcd4_sin : std_logic_vector(3 downto 0);


signal bcd3_3_cos  : std_logic_vector(3 downto 0);
signal bcd3_3_sin  : std_logic_vector(3 downto 0);


signal Anode_Activate_cos, Anode_Activate_sin : STD_LOGIC_VECTOR (3 downto 0);



signal LED_BCD  : STD_LOGIC_VECTOR (3 downto 0);
signal LED_BCD_cos, LED_BCD_sin : STD_LOGIC_VECTOR (3 downto 0);




signal signe_sin : std_logic; --vers une LED;



begin

with Choix_theta select theta <=
	"0011001001000011" when "000",  --  45°
	"0100001100000101" when "001",  --  60°
	"1011110011111010" when "010",  -- -60°
	"0100111000110000" when "011",  --  70°
	"1111011011110010" when "100",  -- -80°
	"0000101100101011" when "101",  --  10°
	"1010000100001110" when "110",  -- -85°
	"0000000000000000" when "111",  --  0°
	"0010001110111111" when others; --  32°





Data_Path : DP port map( reset, clk, theta, 
						 Init_X, Load_X,
						 Init_Y, Load_Y,
						 Init_Z, Load_Z,
						 Init_c, Load_c,
						 CZ,
						 cos, sin
						);


Control_Unit : CU port map( reset, clk, Go, CZ,
						 	Init_X, Load_X,
						 	Init_Y, Load_Y,
						 	Init_Z, Load_Z,
						 	Init_c, Load_c	
						);



Crzyy_cos : bin2fixed_point_bin port map(
								cos, bin_treated_frac_cos, 
								bin_treated_integer_cos, signe_cos
						); 


Crzyy_sin : bin2fixed_point_bin port map(
								sin, bin_treated_frac_sin, 
								bin_treated_integer_sin, signe_sin
						); 



bin_treated_frac_cos_bis <= "00"&bin_treated_frac_cos;
bin_treated_frac_sin_bis <= "00"&bin_treated_frac_sin;



bcd3_3_cos <= "X00"&bin_treated_integer_cos;
bcd3_3_sin <= "X00"&bin_treated_integer_sin;

signe_sin_bric <= theta(15);


fracversBCD_cos : binary_bcd port map(clk, reset, bin_treated_frac_cos_bis, bcd0_cos, bcd1_cos, bcd2_cos, bcd3_cos, bcd4_cos);
-- bcd4 --> MSB

Seg_Ctrl_cos : seven_segment_ctrl port map(clk, reset, bcd1_cos, bcd2_cos, bcd3_cos, bcd3_3_cos, Anode_Activate_cos, LED_BCD_cos);
-- bcd3_3 --> MSB





fracversBCD_sin : binary_bcd port map(clk, reset, bin_treated_frac_sin_bis, bcd0_sin, bcd1_sin, bcd2_sin, bcd3_sin, bcd4_sin);
-- bcd4 --> MSB

Seg_Ctrl_sin : seven_segment_ctrl port map(clk, reset, bcd1_sin, bcd2_sin, bcd3_sin, bcd3_3_sin, Anode_Activate_sin, LED_BCD_sin);
-- bcd3_3 --> MSB



LED_BCD <= LED_BCD_cos when Choix = '0' else LED_BCD_sin;

-- Pour Anode activate on peut faire le même signal
Anode_Activate <= Anode_Activate_cos when Choix = '0' else Anode_Activate_sin;


dec : Decodeur_bcd_7Seg port map(LED_BCD, S_7seg);

end Tooop_arc;