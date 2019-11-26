--DISCLAIMER: dit is een backup van code die NIET werkt

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

signal hPixelTeller: integer range 0 to 800 := 0;
signal vPixelTeller: integer range 0 to 525 := 0;
signal displayAan: std_logic := '0';

--constanten
--timings: lijn (komt overeen met 1 tick van de 25MHz klok)
constant hBackPorchTijd: integer := 48;
constant hFrontPorchTijd: integer := 16;
constant hSyncTijd: integer := 96;
constant hVisTijd: integer := 640;
constant hTotaalTijd: integer := 800;
--timings: frame (komt overeen met 1 lijn = 800 ticks aan 25MHz)
constant vBackPorchTijd: integer := 33;
constant vFrontPorchTijd: integer := 10;
constant vSyncTijd: integer := 2;
constant vVisTijd: integer := 480;
constant vTotaalTijd: integer := 525;

component schermVerticaal
    Port (
        --in
        CLK25MHz: in std_logic;  
        --out      
        hSync : out std_logic;
        vSync : out std_logic;
        hPixelTeller : out integer range 0 to 640;
        vPixelTeller: out integer range 0 to 480;
        displayAan: out std_logic
        );
     end component;
        
begin
    verticaal : schermVerticaal
     Port map( --links component, rechts top design
        CLK25MHz => CLK25MHz,
        hSync => VGA_HS,
        vSync => VGA_VS,
        hPixelTeller => hPixelTeller,
        vPixelTeller => vPixelTeller,
        displayAan => displayAan             
        );
        
    klokConverter: process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if klokTeller >= 2 then
                klokTeller <= 0;
                CLK25MHZ <= not(CLK25MHZ);
            else 
                klokTeller <= klokTeller +1;
            end if;
        end if;
    end process;
    
--    Schermbestuurder: process(CLK25MHz)
--    begin
--        if rising_edge(CLK25MHz) then
--            if vTeller < vTotaalTijd then
--                if hTeller < hTotaalTijd then
--                    hTeller <= hTeller +1;
--                elsif hTeller >= hTotaalTijd then
--                    vTeller <= vTeller +1;
--                    hTeller <= 0;
--                end if;
--            elsif vTeller >= vTotaalTijd then
--                vTeller <= 0;
--            end if;           
--        end if;
--    end process;
    
    kleurGeven : process(displayAan)
    begin
        if(displayAan = '1') then
            VGA_R <= "1111";
        else
            --waardes geven
            VGA_R <= "0000";
            VGA_G <= "0000";
            VGA_B <= "0000";        
        end if;         
    end process;
    
end Behavioral;
