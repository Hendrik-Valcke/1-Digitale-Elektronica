library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity schermHorizontaal is
    Port (
        --in
        CLK25MHz: in std_logic;
        --out
        hSync : out std_logic;        
        hTeller: out integer range 0 to 800;
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
            if teller < hTotaalTijd-1 then
                teller <= teller +1;
            else
                teller <= 0;                
            end if;            
        end if;
    end process;
    
    schermLijnGenerator: process(teller)
    begin
        --standaardwaarden (regels v combinatorisch process)
        hDisplayAan <= '0';
        hSync <= '1';       
        hTeller <= teller;       
        
        if teller <= hVisTijd-1 then
            hDisplayAan <= '1';
            hSync <= '1';
        elsif teller > hVisTijd-1 and teller <= (hVisTijd + hFrontPorchTijd-1) then
            hDisplayAan <= '0';
            hSync <= '1';
        elsif teller >(hVisTijd + hFrontPorchTijd-1) and teller <= (hVisTijd + hFrontPorchTijd + hSyncTijd-1) then
            hDisplayAan <= '0';
            hSync <= '0';
        elsif teller >(hVisTijd + hFrontPorchTijd + hSyncTijd-1) and teller <= (hVisTijd + hFrontPorchTijd + hSyncTijd + hBackPorchTijd-1) then
            hDisplayAan <= '0';
            hSync <= '1';
        end if;
    end process;  
    
end Behavioral;
