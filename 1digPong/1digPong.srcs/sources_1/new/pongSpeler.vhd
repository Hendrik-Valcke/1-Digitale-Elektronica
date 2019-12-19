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
        pauze: in std_logic := '0';
        comeback: in std_logic := '0';
        restart: in std_logic := '0';
        --out      
        botsGeluid: out std_logic;
        winGeluid: out std_logic;
        lSpelerLengte : out integer range 0 to 70;
        rSpelerLengte : out integer range 0 to 70;
        vBal: out integer range 0 to 480;
        hBal: out integer range 0 to 640;
        spelerLinks: out integer range 0 to 480;
        spelerRechts: out integer range 0 to 480;
        scoreLinks: out integer range 0 to 100;
        scoreRechts: out integer range 0 to 100
        );
end pongSpeler;

architecture Behavioral of pongSpeler is
    --constanten
    constant schermBreedte : integer := 640;
    constant schermHoogte : integer := 480;
    constant balDikte : integer := 10;
    constant borderDikte : integer := 5;
    constant spelerDikte : integer := 5;
    
    --signalen        
    signal klokTeller: integer range 0 to 1250000;--zo slowmotion, 1nul wegdoen voor normale teller
    signal telLimiet: integer range 0 to 1250000;  
        
    signal balOmlaag : std_logic :='1';
    signal balRechts: std_logic := '1';
    signal svBal: integer range 0 to 480 := 235;
    signal shBal: integer range 0 to 640 := 315;
    signal vSpelerLinks : integer range 0 to 480 :=215;
    signal vSpelerRechts : integer range 0 to 480 :=215;
    signal linkerScore: integer range 0 to 100 := 0;
    signal rechterScore: integer range 0 to 100 := 0;
    
    signal slSpelerLengte : integer := 70;
    signal srSpelerLengte : integer := 70;

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
            if restart = '0' then
                if pauze = '0' then                
                    if klokTeller >= telLimiet then--dus 100Hz--1nul wegdoen!
                        klokTeller <= 0;
                        botsGeluid <= '0';
                        winGeluid <= '0';
                        --bewegen van de palletjes
                        --linkerpallet
                        if BTNU = '1' and vSpelerLinks > borderDikte then--5
                            vSpelerLinks <= vSpelerLinks -1;
                        elsif BTNL = '1' and vSpelerLinks < schermHoogte - borderDikte - slSpelerLengte then --475-50
                            vSpelerLinks <= vSpelerLinks +1;                    
                        end if;
                        --rechterpallet
                        if BTNR = '1' and vSpelerRechts > borderDikte then --5
                            vSpelerRechts <= vSpelerRechts -1;
                        elsif BTND = '1' and vSpelerRechts < schermHoogte - borderDikte - srSpelerLengte then
                            vSpelerRechts <= vSpelerRechts +1;                    
                        end if;
                        --bewegen van de bal
                        --verticaal
                        if balOmlaag = '1' and svBal <  schermHoogte - borderDikte - balDikte then--480-15
                            svBal <= svBal+1;                                  
                        elsif balOmlaag='1' and svBal >= schermHoogte - borderDikte - balDikte then--480-15 botsing
                            svBal <= svBal -1;
                            balOmlaag <= '0';
                            botsGeluid <= '1';
                        elsif balOmlaag = '0' and svBal >borderDikte then--5
                            svBal <= svBal-1;                    
                        elsif balOmlaag = '0' and svBal <= borderDikte then--5 botsing
                            svBal <= svBal+1;
                            balOmlaag <= '1';
                            botsGeluid <= '1';
                        end if;
                        --horizontaal, hier wordt ook op doelpunten gecheckt en de score aangepast
                        if balRechts = '1' and shBal < schermBreedte - borderDikte - balDikte -spelerDikte then --640-15-5
                            shBal <= shBal+1; 
                        elsif balRechts = '1' and shBal >=schermBreedte - borderDikte - balDikte -spelerDikte then--in buurt van rechter kader
                            shBal <= shBal+1; 
                            if svBal<vSpelerRechts+srSpelerLengte and svBaL+balDikte >= vSpelerRechts then--renderBal = '1' and renderRspeler = '1' then
                                shBal <= shBal -1;
                                balRechts <= '0';
                                botsGeluid <= '1';                               
                            elsif shBal >= schermBreedte - borderDikte - balDikte then --640-15 botsing met rechterkader
                                if comeback ='1' and slSpelerLengte > 20 then
                                    slSpelerLengte <= slSpelerlengte - 5;
                                end if;
                                linkerScore <= linkerScore +1;
                                winGeluid <= '1';
                                svBal<= 235;
                                shBal <= 315;
                                balRechts <= '0';
                            end if;
                        elsif balRechts = '0' and shBal > borderDikte + spelerdikte then --5+5
                            shBal <= shBal-1;         
                        elsif balRechts = '0' and shBal <= borderDikte + spelerDikte then --5 in buurt van linkerkader
                            shBal <= shBal -1;
                            if svBal<vSpelerLinks+slSpelerLengte and svBaL+balDikte >= vSpelerLinks then--renderBal = '1' and renderLspeler = '1' then
                                shBal <= shBal+1;
                                balRechts <= '1';
                                botsGeluid <= '1';
                            elsif shBal <= borderDikte then
                                if comeback ='1' and srSpelerLengte > 20 then
                                    srSpelerLengte <= srSpelerlengte - 5;
                                end if;
                                rechterScore <= rechterScore +1;
                                winGeluid <= '1';
                                svBal<= 235;
                                shBal <= 315;
                                balRechts <= '1';
                            end if;
                        end if;
                    else
                        klokteller <= klokteller +1;
                    end if;
                end if;
                elsif restart = '1' then
                    slSPelerLengte <= 70;
                    srSpelerLengte <= 70;
                    linkerscore <= 0;    
                    rechterScore <= 0;   
                    vSpelerLinks <= 205; 
                    vSpelerRechts <= 205;
                    shBal <= 315;        
                    svBal <= 235;        
                    balOmlaag <= '1';    
                    balRechts <= '1';    
               end if;
        end if;
    end process;
        
    doorgeven: process(slSpelerLengte,srSpelerlengte,linkerScore,rechterScore,vSpelerLinks,vSpelerRechts,svBal,shBal)
    begin
        spelerLinks <= vSpelerLinks;
        spelerRechts <= vSpelerRechts;
        vBal<=svBal;
        hBal<=shBal;
        scoreLinks <= linkerScore;
        scoreRechts <= rechterScore;
        lSpelerLengte <= slSpelerLengte;
        rSpelerlengte <= srSpelerLengte;
    end process;   


end Behavioral;
