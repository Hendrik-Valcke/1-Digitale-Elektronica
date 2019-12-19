--pong zelf werkt, scorebord verwisseld de eenheden van links en rechts om de een of andere reden (tientallen zijn wel juist)
--controls: 
--links: BTNU => up, BTNL => down, rechts BTNR => up, BTND => down
--BTNC: restart
--SW[0] => slowmotion (voor beter te zien waar het foutloopt)
--SW[1] => pauze: '1' pauzeert, '0' laat spel normaal verlopen
--SW[2] => comeback mode: palletje van scoorder wordt kleiner bij doelpunt
--SW[3] => rechterspeler wordt vervangen door AI
--sw(15)=> geluid

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity pongScherm is
    Port ( 
        --in
        CLK100MHZ: in std_logic; -- de 100MHz klok van het bordje zelf, deze kan je niet aanpassen
        BTNU: in std_logic ; --knop boven (spelerLinks omhoog/ kleinere waarde)
        BTNL: in std_logic ; --knop links (spelerLinks omlaag/grotere waarde)
        BTNR: in std_logic ; --knop rechts (spelerRechts omhoog/ kleinere waarde)
        BTND: in std_logic ; --knop beneden (spelerRechts omlaag/grotere waarde)
        slomo: in std_logic; --slowmotion SW0
        pauze: in std_logic := '0'; --pauze knopSW1
        comeback: in std_logic := '0'; --comeback modeSW2
        speelSound: in std_logic := '0';--sw(15)
        AImode: in std_logic := '0';--SW3
        speelDeun: in std_logic := '0'; --sw4
        restart: in std_logic := '0'; --restart (BTNC)
        --out
        --sound
        AUD_PWM: out std_logic := '0';
        AUD_SD: out std_logic := '0';
        --vga
        VGA_R: out std_logic_vector(3 downto 0);
        VGA_G: out std_logic_vector(3 downto 0);
        VGA_B: out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;--
        --7segment
        AN: out std_logic_vector(7 downto 0);--anodes        
        CA: out std_logic;--cathodes: actief ???
        CB: out std_logic;
        CC: out std_logic;
        CD: out std_logic;
        CE: out std_logic;
        CF: out std_logic;
        CG: out std_logic
        );
end pongScherm;

architecture Behavioral of pongScherm is
    --constanten
    constant schermBreedte : integer := 640;
    constant schermHoogte : integer := 480; 
    constant balDikte : integer := 10;      
    constant borderDikte : integer := 5;    
    constant spelerDikte : integer := 5;    
    --signalen
    signal CLK25MHZ: std_logic := '0'; --door dit signaal te veranderen bootsen we een klok van 20Hz na
    signal klokTeller: integer range 0 to 2500000 := 0; -- dit signaal tellen we op, als het 2 500 000 bereikt verandert het signaal van CLK20Hz

    signal displayAan: std_logic := '0';
    signal hLocatie: integer range 0 to 800;
    signal vLocatie: integer range 0 to 525;

    signal rUp: std_logic :='0';
    signal rDown : std_logic := '0';
    signal srUp: std_logic :='0';
    signal srDown : std_logic := '0';
    
    signal botsGeluid: std_logic := '0';
    signal winGeluid: std_logic := '0';
    
    signal lSpelerLengte: integer range 0 to 70 := 70;
    signal rSpelerLengte : integer range 0 to 70 := 70;
    signal hBal: integer range 0 to 640;
    signal vBal: integer range 0 to 480;
    signal spelerLinks: integer range 0 to 480 := 0; --de coordinaat van de bovenste pixels vd speler
    signal spelerRechts: integer range 0 to 480 := 0; --de coordinaat van de bovenste pixels vd speler
    signal scoreLinks: integer range 0 to 100 := 0;
    signal scoreRechts: integer range 0 to 100 := 0;

    component schermVerticaal
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
    end component;
    
    component AI
    Port (
        --in
        CLK25MHz: in std_logic; 
        AImode: in std_logic := '0';
        --hBal: in integer range 0 to 640;
        vBal: in integer range 0 to 480;
        spelerRechts: in integer range 0 to 480;
        rSpelerLengte: in integer range 0 to 70;
        --out
        rUp: out std_logic := '0';
        rDown: out std_logic := '0'
        );
    end component;
     
    component pongSpeler
    Port (
        --in
        CLK25MHz: in std_logic;  
        BTNU: in std_logic ; --knop boven (spelerLinks omhoog/ kleinere waarde)
        BTNL: in std_logic ; --knop links (spelerLinks omlaag/grotere waarde)
        BTNR: in std_logic ; --knop rechts (spelerRechts omhoog/ kleinere waarde)
        BTND: in std_logic ; --knop beneden (spelerRechts omlaag/grotere waarde)
        slomo: in std_logic ; --slowmotion
        pauze: in std_logic;
        comeback: in std_logic;
        restart: in std_logic;
        --out  
        botsGeluid: out std_logic; 
        winGeluid : out std_logic;   
        lSpelerLengte : out integer range 0 to 70;
        rSpelerLengte : out integer range 0 to 70;
        vBal: out integer range 0 to 480;
        hBal: out integer range 0 to 640;
        spelerLinks: out integer range 0 to 480;
        spelerRechts: out integer range 0 to 480;
        scoreLinks: out integer range 0 to 100;
        scoreRechts : out integer range 0 to 100
        );
     end component;
    
    component Sound
    Port(
        --in
        CLK25MHz: in std_logic;
        winGeluid: in std_logic;
        speelDeun: in std_logic;
        --out
        AUD_pwm: out std_logic
        );
    end component;
     
    component displayScore
    port(
        --in
       CLK25MHz: in std_logic;
       scoreLinks: in integer range 0 to 100;
       scoreRechts: in integer range 0 to 100;
       slomo: in std_logic;
       --out
       AN: out std_logic_vector(7 downto 0);--anodes        
       CA: out std_logic;--cathodes: 
       CB: out std_logic;
       CC: out std_logic;
       CD: out std_logic;
       CE: out std_logic;
       CF: out std_logic;
       CG: out std_logic
        );
    end component;
        
begin
    geluid: Sound
    Port map (
            --in
            CLK25MHz=> CLK25MHz,
            winGeluid=>winGeluid,
            speelDeun => speelDeun,
            --out
            aud_pwm=>aud_pwm
            );
    
    verticaal : schermVerticaal
    Port map( --links component, rechts top design
        --in
        CLK25MHz => CLK25MHz,
        --out
        hSync => VGA_HS,
        vSync => VGA_VS,        
        displayAan => displayAan,  
        hLocatie => hLocatie,
        vLocatie => vLocatie                           
        );
        
    AIproces : AI
    Port map (
            --in
            CLK25MHZ => CLK25MHZ,
            AImode => AImode,
            vBal=>vBal,
            spelerRechts=>spelerRechts,
            rSpelerLengte =>rSpelerLengte,
            --out
            rUp=>srUp,
            rDown=>srDown            
            );
        
    spelers : PongSPeler
    Port map(
        --in
        CLK25MHz => CLK25MHz,
        BTNU => BTNU,
        BTNL => BTNL,        
        BTNR => rUp,
        BTND => rDown,
        slomo => slomo,
        pauze => pauze,
        comeback => comeback,
        restart => restart,
        --out
        botsGeluid=>botsGeluid,
        wingeluid=>wingeluid,
        lSpelerLengte => lSpelerLengte,
        rSPelerLengte => rSpelerLengte,
        hBal=> hBal,
        vBal => vBal,
        spelerLinks => spelerLinks,
        spelerRechts => spelerRechts,
        scoreLinks => scoreLinks,
        scoreRechts => scoreRechts
        );    
        
    score: displayScore
    port map(
            --in
       CLK25MHz=>CLK25MHZ,
       scoreLinks => scoreLinks,
       scoreRechts => scoreRechts,
       slomo=>slomo,
       --out
       AN=>AN,       
       CA=>CA,
       CB=>CB,
       CC=>CC,
       CD=>CD,
       CE=>CE,
       CF=>CF,
       CG=>CG        
        );
        
    
    speelSoundTest: process(speelSound,botsGeluid,winGeluid)
    begin
        if speelSound = '1' or botsGeluid = '1' or winGeluid = '1' then
            aud_sd <= '1';
        else
            aud_sd <='0';
        end if;
    end process;
    
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
    
    AIswitch: process(AImode,BTNR,BTND,srUp,srDown)
    begin
        if AImode = '1' then
            rUp<=srUp;
            rDown <= srDOwn;
        else 
            rUp <= BTNR;
            rDown<=BTND;
        end if;
    end process;
    
    kleurGeven : process(pauze,displayAan,hLocatie,vLocatie,spelerLinks,spelerRechts,lSpelerLengte,rSpelerLengte,vBal,hBal)
    begin
        if(displayAan = '1') then
            VGA_R <= "0000";--basiskleuren van het veld
            VGA_G <= "0111";
            VGA_B <= "0000";                      
            
            if (vLocatie >= vBal and vLocatie < vBal+balDikte and hLocatie >= hBal and hLocatie < hBal+balDikte) then-- het balletje 
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";         
            end if;
            if pauze = '1' then -- pauze symbool
                if vLocatie >= 200 and vLocatie < 260 and ((hLocatie >= 300 and hLocatie < 310) or  (hLocatie >= 330 and hLocatie < 340)) then
                    VGA_R <= "0111";
                    VGA_G <= "0111";
                    VGA_B <= "0111";  
                end if;
            end if;  
                        
            if(hLocatie<=borderDikte or hLocatie >= schermBreedte - borderDikte )then--de borders aan de zijkant -- 5 en 635
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
            end if;
            if (vLocatie <= borderDikte or vLocatie >= schermHoogte -borderDikte) or (hLocatie >= 318 and hLocatie <= 322)then--de middellijn en de border vanboven en beneden
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
            end if;    
            if (hLocatie >borderDikte  and hLocatie<= borderDIkte + spelerDikte) and (vLocatie > spelerLinks and vLocatie<= spelerLinks + lSpelerLengte) then    --linkerpallet
                VGA_R <= "1111";
                VGA_G <= "0000";
                VGA_B <= "0000";
            end if; 
            if (hLocatie >= schermBreedte - borderDikte -spelerDikte  and hLocatie<schermBreedte - borderDikte) and (vLocatie > spelerRechts and vLocatie<= spelerRechts + rSpelerLengte) then    --rechterpallet
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "0000";
            end if; 
        else --niks doorsturen tijdens de syncs/porches
            VGA_R <= "0000";
            VGA_G <= "0000";
            VGA_B <= "0000";                 
        end if;         
    end process;
    
end Behavioral;
