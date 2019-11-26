--DISCLAIMER: dit is een backup van code die NIET werkt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity schermHorizontaal is
    Port (
        --in
        CLK25MHz: in std_logic;
        --out
        hSync : out std_logic;
        hPixelTeller : out integer range 0 to 640;
        hDisplayAan: out std_logic 
        );
end schermHorizontaal;

architecture Behavioral of schermHorizontaal is
--signalen
signal teller: integer range 0 to 800;
--constanten
--timings: lijn (komt overeen met 1 tick van de 25MHz klok)
constant hBackPorchTijd: integer := 48;
constant hFrontPorchTijd: integer := 16;
constant hSyncTijd: integer := 96;
constant hVisTijd: integer := 640;
constant hTotaalTijd: integer := 800;

begin
    telKlok: process(CLK25MHZ)
    begin
        if rising_edge(CLK25MHz) then
            if teller < hTotaalTijd then
                teller <= teller +1;
            else
                teller <= 0;                
            end if;            
        end if;
    end process;
    
    schermLijnGenerator: process(teller)
    begin
        --standaardwaarden (regels v combinatorisch process
--        hDisplayAan <= '0';
--        hSync <= '0';
--        hPixelTeller <= 0;
        
        --hPixelTeller (poort) de waarde van teller meegeven
        hPixelTeller <= teller;
        
        if teller <= hVisTijd then
            hDisplayAan <= '1';
            hSync <= '1';
            --hPixelTeller <= teller;
        elsif teller > hVisTijd and teller <= (hVisTijd + hFrontPorchTijd) then
            hDisplayAan <= '0';
            hSync <= '1';
        elsif teller >(hVisTijd + hFrontPorchTijd) and teller <= (hVisTijd + hFrontPorchTijd + hSyncTijd) then
            hDisplayAan <= '0';
            hSync <= '0';
        elsif teller >(hVisTijd + hFrontPorchTijd + hSyncTijd) and teller <= (hVisTijd + hFrontPorchTijd + hSyncTijd + hBackPorchTijd) then
            hDisplayAan <= '0';
            hSync <= '1';
        end if;
    end process;
    
    

end Behavioral;
