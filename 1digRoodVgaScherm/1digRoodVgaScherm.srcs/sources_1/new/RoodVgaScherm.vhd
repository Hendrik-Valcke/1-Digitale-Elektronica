library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity RoodVgaScherm is
    Port ( 
        --in
        CLK100MHZ: in std_logic; -- de 100MHz klok van het bordje zelf, deze kan je niet aanpassen
        --out
        VGA_R: out std_logic_vector(3 downto 0);
        VGA_G: out std_logic_vector(3 downto 0);
        VGA_B: out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic
    );
end RoodVgaScherm;

architecture Behavioral of RoodVgaScherm is

--signalen
signal CLK25MHZ:std_logic := '0'; --door dit signaal te veranderen bootsen we een klok van 20Hz na
signal klokTeller: integer range 0 to 2500000 := 0; -- dit signaal tellen we op, als het 2 500 000 bereikt verandert het signaal van CLK20Hz

signal displayAan: std_logic := '0';

component schermVerticaal
    Port (
        --in
        CLK25MHz: in std_logic;  
        --out      
        hSync : out std_logic;
        vSync : out std_logic;        
        displayAan: out std_logic
        );
     end component;
        
begin
    verticaal : schermVerticaal
     Port map( --links component, rechts top design
        --in
        CLK25MHz => CLK25MHz,
        --out
        hSync => VGA_HS,
        vSync => VGA_VS,        
        displayAan => displayAan             
        );
        
    klokConverter: process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if klokTeller >= 1 then
                klokTeller <= 0;
                CLK25MHZ <= not(CLK25MHZ);
            else 
                klokTeller <= klokTeller +1;
            end if;
        end if;
    end process;
    
    kleurGeven : process(displayAan)
    begin
        VGA_R <= "0000";
        VGA_G <= "0000";
        VGA_B <= "0000";
        if(displayAan = '1') then
            VGA_R <= "1111";        
        end if;         
    end process;
    
end Behavioral;
