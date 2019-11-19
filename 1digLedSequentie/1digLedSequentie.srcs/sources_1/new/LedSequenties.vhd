--Maak een looplicht met een 20 Hz klokfrequentie.
--Er brandt altijd exact één LED in volgende sequentie:
--  LED15 t.e.m. LED0
--  LED1 t.e.m. LED14
--  LED15 t.e.m. LED0
--Een synchrone reset brengt het looplicht naar de begintoestand.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity LedSequenties is
    Port ( 
        --in
        CLK100MHZ: in std_logic; -- de 100MHz klok van het bordje zelf, deze kan je niet aanpassen
        reset : in std_logic; --BTNC in 
        --out
        LED: out std_logic_vector(15 downto 0) --LED 15 staat links, LED 0 rechts
    );
end LedSequenties;

architecture Behavioral of LedSequenties is
--signalen
signal CLK20HZ:std_logic := '0'; --door dit signaal te veranderen bootsen we een klok van 20Hz na
signal terugkeren: std_logic := '0'; --de led gaat terug naar links
signal klokTeller: integer range 0 to 2500000 := 0; -- dit signaal tellen we op, als het 2 500 000 bereikt verandert het signaal van CLK20Hz
signal ledTeller: integer range 0 to 15 := 0; -- met deze teller houden we bij hoeveel naar links we zitten qua LED
--type
type machtArray is array(0 to 15) of integer range 0 to 32768;-- een type array met 16 elementen van type integer
    constant machtVan2: machtArray:= --een array waarvan het n-de element overeenstemt met 2^n
    (1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768); 

begin
--de CLK100MHZ geeft elke 1/(10^8) een '1'
--we willen om de 1/20 seconde een '1'
--dus om de 5 000 000 ticks aan een snelheid van 100MHZ is er 1/20 sec voorbij maar hij moet halverwege de periode van hoog naar laag en andersom gaan dus 2 500 000
    klokConverter: process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if klokTeller >= 2500000 then
                klokTeller <= 0;
                CLK20HZ <= not(CLK20HZ);
            else 
                klokTeller <= klokTeller +1;
            end if;
        end if;
    end process;
    
    ledBestuurder: process(CLK20HZ)
    begin
        
        if rising_edge(CLK20HZ) then
            if ledTeller < 15 and terugkeren = '0' then --heengaan
                ledTeller <= ledTeller +1;
            elsif ledTeller >= 15  and terugkeren = '0' then --heeft einde bereikt
                ledTeller <= ledTeller -1;
                terugkeren <= '1'; 
            elsif ledTeller > 0 and terugkeren = '1' then --terug gaan
                ledTeller <= ledTeller -1;
            elsif ledTeller <= 0 and terugkeren = '1' then -- heeft begin bereikt
                ledTeller <= ledTeller +1;
                terugkeren <= '0';                
            end if;
            
            if reset = '1' then
                ledTeller <= 0;
                terugkeren <= '0';
            end if;
            --we geven de LED als std_logic_vector een binair getal = 2^(15-ledTeller) bv 0000000000000001 = 2^0 dus ledTeller = 15 (de meest rechtse led)
            LED <= std_logic_vector(to_unsigned(machtVan2(15-ledTeller),16));
        end if;     
    end process;

end Behavioral;
