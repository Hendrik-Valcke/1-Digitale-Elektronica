--DISCLAIMER: dit is een backup van code die NIET werkt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity schermVerticaal is
    Port (
        --in
        CLK25MHz: in std_logic;
        --out
        hSync : out std_logic;
        vSync : out std_logic;
        hPixelTeller : out integer range 0 to 640;
        vPixelTeller : out integer range 0 to 480;
        displayAan: out std_logic 
     );
end schermVerticaal;

architecture Behavioral of schermVerticaal is
--signalen
signal hDisplayAan: std_logic;
signal vDisplayAan: std_logic;
signal hTeller: integer range 0 to 800;
signal vTeller: integer range 0 to 525;

--constanten
--timings: lijn (komt overeen met 1 tick van de 25MHz klok)
--constant hBackPorchTijd: integer := 48;
--constant hFrontPorchTijd: integer := 16;
--constant hSyncTijd: integer := 96;
--constant hVisTijd: integer := 640;
--constant hTotaalTijd: integer := 800;

--timings: frame (komt overeen met 1 lijn = 800 ticks aan 25MHz)
constant vBackPorchTijd: integer := 33;
constant vFrontPorchTijd: integer := 10;
constant vSyncTijd: integer := 2;
constant vVisTijd: integer := 480;
constant vTotaalTijd: integer := 525;

component schermHorizontaal
    Port(
        CLK25MHz : in std_logic;
        hDisplayAan: out std_logic;
        hPixelteller: out integer range 0 to 640;
        hSync: out std_logic
        --hTeller: out integer
        );
    end component;

begin

    horizontaal: schermHorizontaal
    Port map(
             CLK25MHz => CLK25MHz,
             hPixelTeller => hPixelTeller,
             hDIsplayAan => DisplayAan,
             hSync => hSync             
            );
    
    telKlok: process(CLK25MHz)
    begin
        if rising_edge(CLK25MHz) then
            if hTeller >=800 then
                if vTeller < vTotaalTijd then
                    vTeller <= vTeller +1;
                else
                    vTeller <= 0;
                end if;
            end if;
        end if;
    end process;
            
    SchermFrameGenerator: process(vTeller)
    begin
        --standaardwaarden (combinatorisch process)
--        vDisplayAan <= '0';
--        vSync <= '0';
--        vPixelTeller <= 0;
        
        if vTeller <= vVisTijd then
            vDisplayAan <= '1';
            vSync <= '1';
            vPixelTeller <= vTeller;
        elsif vTeller > vVistijd and vTeller <= (vVisTijd + vFrontPorchTijd) then
            vDisplayAan <= '0';
            vSync <= '1';
        elsif vTeller > (vVisTijd + vFrontPorchTijd) and vTeller <=(vVisTijd + vFrontPorchTijd + vSyncTijd) then
            vDisplayAan <= '0';
            vSync <= '0';
        elsif vTeller > (vVisTijd + vFrontPorchTijd + vSyncTijd) and vTeller <= (vVisTijd + vFrontPorchTijd + vSyncTijd + vBackPorchTijd)then
            vDisplayAan <= '0';
            vSync <= '1';
        end if;
    end process;
    
    displayAan <= hDisplayAan and vDisplayAan;

end Behavioral;
