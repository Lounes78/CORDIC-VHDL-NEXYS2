library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions


entity CU is
	port (
			reset, clk, Go, CZ  : IN std_logic;

			Init_X, Load_X : OUT std_logic;
			Init_Y, Load_Y : OUT std_logic;
			Init_Z, Load_Z : OUT std_logic; -- Sens de Rotation
			Init_c, Load_c : OUT std_logic -- Nombre d'itérations
		
	);
end CU;



architecture CU_arc of CU is

type Etat is (Idle, IT, Cnt, Shift, disp);
signal E : Etat := Idle;

begin
	Init_X <='1' when E = Idle else '0';
	Init_Y <='1' when E = Idle else '0';
	Init_Z <= '1' when E = Idle else '0';
	Init_c <= '1' when E = Idle else '0';
	
	Load_X <='1' when E = IT else '0';
	Load_Y <='1' when E = IT else '0';

	
	Load_Z <= '1' when E = Cnt else '0';
	Load_c <= '1' when E = Cnt else '0';



	process (reset, clk)
	begin
	  if (reset = '1') then
		E <= Idle;

	  elsif (rising_edge(clk)) then
	  	case(E) is
	  		when Idle => if Go = '1' then E <= IT; else E <= Idle; end if;
	  			
	  		when IT => E <= Cnt;
	  			
	  		when Cnt => if Cz = '1' then E <= disp; else E <= Shift; end if;
	  			
	  		when Shift => E <= IT;

	  		when disp => E <= disp;

	  	end case;
	  end if;
	end process;





end CU_arc;