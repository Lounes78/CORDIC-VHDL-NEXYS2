library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions

entity seven_segment_ctrl is
    Port ( clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           bcd0, bcd1, bcd2, bcd3 : IN STD_LOGIC_VECTOR (3 downto 0);

           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);
           LED_BCD        : out STD_LOGIC_VECTOR (3 downto 0)

           );
end seven_segment_ctrl;




architecture seven_segment_ctrl_arc of seven_segment_ctrl is
signal refresh_counter : std_logic_vector (17 downto 0);
signal LED_activating_counter : std_logic_vector (1 downto 0);


begin


process(clk,reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clk)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;

 LED_activating_counter <= refresh_counter(17 downto 16);

process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "00" =>
        Anode_Activate <= "0111"; -- LED MSB

        LED_BCD <= bcd3;
        
    when "01" =>
        Anode_Activate <= "1011"; -- LED 3
        
        LED_BCD <= bcd2;
        
    when "10" =>
        Anode_Activate <= "1101"; -- LED 2
        
        LED_BCD <= bcd1;
        
    when "11" =>
        Anode_Activate <= "1110"; -- LED LSB
        
        LED_BCD <= bcd0;
    when others =>
        Anode_Activate <= "1111";
    end case;
end process;




end seven_segment_ctrl_arc;
