library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity schermVerticaal is
    Port (
        --in
        CLK25MHz: in std_logic;
        --out
        hSync : out std_logic;
        vSync : out std_logic;        
        displayAan: out std_logic;
        hLocatie: out integer range 0 to 800;
        vLocatie: out integer range 0 to 525
     );
end schermVerticaal;

architecture Behavioral of schermVerticaal is
--signalen
signal hDisplayAan: std_logic;
signal vDisplayAan: std_logic;
signal hTeller: integer range 0 to 800;
signal vTeller: integer range 0 to 525;

--timings: frame (komt overeen met 1 lijn = 800 ticks aan 25MHz)
constant vBackPorchTijd: integer := 33;
constant vFrontPorchTijd: integer := 10;
constant vSyncTijd: integer := 2;
constant vVisTijd: integer := 480;
constant vTotaalTijd: integer := 525;

component schermHorizontaal
    Port(
        --in
        CLK25MHz : in std_logic;
        --out   
        hSync: out std_logic;
        hDisplayAan: out std_logic;
        hTeller: out integer range 0 to 800        
        );
    end component;

begin

    horizontaal: schermHorizontaal
    Port map(            
            --in
            CLK25MHz => CLK25MHz,
            --out                 
            hSync => hSync, 
            hDisplayAan => hDisplayAan,
            hTeller=> hTeller          
            );
    
    telKlok: process(CLK25MHz)
    begin
        if rising_edge(CLK25MHz) then
            if hTeller =0 then
                if vTeller < vTotaalTijd-1 then
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
        vSync <= '1';
        vDisplayAan <= '0';
        
        if vTeller <= vVisTijd-1 then
            vDisplayAan <= '1';
            vSync <= '1';
        elsif vTeller > vVistijd-1 and vTeller <= (vVisTijd + vFrontPorchTijd-1) then
            vDisplayAan <= '0';
            vSync <= '1';
        elsif vTeller > (vVisTijd + vFrontPorchTijd-1) and vTeller <=(vVisTijd + vFrontPorchTijd + vSyncTijd-1) then
            vDisplayAan <= '0';
            vSync <= '0';
        elsif vTeller > (vVisTijd + vFrontPorchTijd + vSyncTijd-1) and vTeller <= (vVisTijd + vFrontPorchTijd + vSyncTijd + vBackPorchTijd-1)then
            vDisplayAan <= '0';
            vSync <= '1';
        end if;
    end process;
    
    display: process(hDisplayAan,vDisplayAan)
    begin
        displayAan <= hDisplayAan and vDisplayAan;
    end process;
    
    locaties: process(hTeller, vTeller)
    begin
        hLocatie<= hTeller;
        vLocatie <= vTeller;
    end process;

end Behavioral;
