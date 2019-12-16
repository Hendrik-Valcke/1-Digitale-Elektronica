library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pongSpeler is
    Port (
        CLK25MHz: in std_logic;  
        BTNU: in std_logic :='0' ; --knop boven (spelerLinks omhoog/ kleinere waarde)
        BTNL: in std_logic :='0' ; --knop links (spelerLinks omlaag/grotere waarde)
        BTNR: in std_logic :='0' ; --knop rechts (spelerRechts omhoog/ kleinere waarde)
        BTND: in std_logic :='0'; --knop beneden (spelerRechts omlaag/grotere waarde)
        slomo: in std_logic := '0';
--        renderBal: in std_logic := '0';
--        renderLspeler: in std_logic := '0';
--        renderRspeler: in std_logic := '0';
--        renderBorder: in std_logic := '0';
        --out      
        vBal: out integer range 0 to 480;
        hBal: out integer range 0 to 640;
        spelerLinks: out integer range 0 to 480;
        spelerRechts: out integer range 0 to 480;
        lWint: out std_logic := '0';
        rWint: out std_logic := '0'
        );
end pongSpeler;

architecture Behavioral of pongSpeler is
    --constanten
    constant schermBreedte : integer := 640;
    constant schermHoogte : integer := 480;
    constant balDikte : integer := 10;
    constant borderDikte : integer := 5;
    constant spelerDikte : integer := 5;
    constant spelerLengte : integer := 50;
    --signelen
--    signal renderBal: std_logic := '0';
--    signal renderLinkerSpeler: std_logic := '0';
--    signal renderRechterSpeler: std_logic := '0';
--    signal renderBorder: std_logic := '0';
        
    signal klokTeller: integer range 0 to 1250000;--zo slowmotion, 1nul wegdoen voor normale teller
    signal telLimiet: integer range 0 to 1250000;
    
    signal balOmlaag : std_logic :='1';
    signal balRechts: std_logic := '1';
    signal svBal: integer range 0 to 480 := 235;
    signal shBal: integer range 0 to 640 := 315;
    signal vSpelerLinks : integer range 0 to 480 :=215;
    signal vSpelerRechts : integer range 0 to 480 :=215;
    signal linksWInt: std_logic := '0';
    signal rechtsWInt: std_logic := '0';

begin
    slowmotion: process(slomo)
    begin
        if slomo = '1' then
            telLimiet <= 1249999; --10Hz
        else
            telLimiet <= 124999;--100Hz
        end if;
    end process;

    speler: process(CLK25MHz)
    begin
        if rising_edge(CLK25MHz)then
        linksWint <= '0';
        rechtsWint <= '0';
            if klokTeller >= telLimiet then--dus 100Hz--1nul wegdoen!
                klokTeller <= 0;
                --bewegen van de palletjes
                --linkerpallet
                if BTNU = '1' and vSpelerLinks > borderDikte then--5
                    vSpelerLinks <= vSpelerLinks -1;
                elsif BTNL = '1' and vSpelerLinks < schermHoogte - borderDikte - spelerLengte then --475-50
                    vSpelerLinks <= vSpelerLinks +1;                    
                end if;
                --rechterpallet
                if BTNR = '1' and vSpelerRechts > borderDikte then --5
                    vSpelerRechts <= vSpelerRechts -1;
                elsif BTND = '1' and vSpelerRechts < schermHoogte - borderDikte - spelerLengte then
                    vSpelerRechts <= vSpelerRechts +1;                    
                end if;
                --bewegen van de bal
                --verticaal
                if balOmlaag = '1' and svBal <  schermHoogte - borderDikte - balDikte then--480-15
                    svBal <= svBal+1;                                  
                elsif balOmlaag='1' and svBal >= schermHoogte - borderDikte - balDikte then--480-15 botsing
                    svBal <= svBal -1;
                    balOmlaag <= '0';
                elsif balOmlaag = '0' and svBal >borderDikte then--5
                    svBal <= svBal-1;                    
                elsif balOmlaag = '0' and svBal <= borderDikte then--5 botsing
                    svBal <= svBal+1;
                    balOmlaag <= '1';
                end if;
                --horizontaal
                if balRechts = '1' and shBal < schermBreedte - borderDikte - balDikte -spelerdikte then --640-15-5
                    shBal <= shBal+1; 
                    linksWint <= '0';   
                elsif balRechts = '1' and shBal >=schermBreedte - borderDikte - balDikte -spelerDikte then--in buurt van rechter kader
                    shBal <= shBal+1; 
                    linksWint <= '0';
                    if svBal<vSpelerRechts+spelerLengte and svBaL+balDikte >= vSpelerRechts then--renderBal = '1' and renderRspeler = '1' then
                        shBal <= shBal -1;
                        balRechts <= '0';
                        linksWint <= '0';                                   
                    elsif shBal >= schermBreedte - borderDikte - balDikte then --640-15 botsing met rechterkader
                        linksWint <= '1';
                        svBal<= 235;
                        shBal <= 315;
                        balRechts <= '0';
--                        shBal <= shBal -1;
--                        balRechts <= '0';
                    end if;
                elsif balRechts = '0' and shBal > borderDikte + spelerdikte then --5+5
                    shBal <= shBal-1; 
                    rechtsWint<='0';                   
                elsif balRechts = '0' and shBal <= borderDikte + spelerDikte then --5 in buurt van linkerkader
                    shBal <= shBal -1;
                    rechtsWint<='0';
                    if svBal<vSpelerLinks+spelerLengte and svBaL+balDikte >= vSpelerLinks then--renderBal = '1' and renderLspeler = '1' then
                        shBal <= shBal+1;
                        balRechts <= '1';
                        rechtsWint<='0';
                    elsif shBal <= borderDikte then
                        rechtsWint<='1';
                        svBal<= 235;
                        shBal <= 315;
                        balRechts <= '1';
                    end if;
                end if;
            else
                klokteller <= klokteller +1;
            end if;
        end if;
    end process;
        
    doorgeven: process(linksWint,rechtsWint,vSpelerLinks,vSpelerRechts,svBal,shBal)
    begin
        spelerLinks <= vSpelerLinks;
        spelerRechts <= vSpelerRechts;
        vBal<=svBal;
        hBal<=shBal;
        lWInt<=linksWint;
        rWint<=rechtsWint;
    end process;
    


end Behavioral;
