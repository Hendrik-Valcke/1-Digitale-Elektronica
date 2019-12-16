--pong zelf werkt, scorebord nog niet

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
        slomo: in std_logic; --slowmotion
        --out
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
    --signalen
    signal CLK25MHZ: std_logic := '0'; --door dit signaal te veranderen bootsen we een klok van 20Hz na
    signal klokTeller: integer range 0 to 2500000 := 0; -- dit signaal tellen we op, als het 2 500 000 bereikt verandert het signaal van CLK20Hz

    signal displayAan: std_logic := '0';
    signal hLocatie: integer range 0 to 800;
    signal vLocatie: integer range 0 to 525;
    
--    signal renderBal: std_logic := '0';
--    signal renderLspeler : std_logic := '0';
--    signal renderRspeler : std_logic := '0';
--    signal renderBorder: std_logic := '0';
    
    signal hBal: integer range 0 to 640;
    signal vBal: integer range 0 to 480;
    signal spelerLinks: integer range 0 to 480 := 0; --de coordinaat van de bovenste pixels vd speler
    signal spelerRechts: integer range 0 to 480 := 0; --de coordinaat van de bovenste pixels vd speler
    signal lWInt: std_logic:= '0';
    signal rWint: std_logic := '0';

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
     
    component pongSpeler
    Port (
        --in
        CLK25MHz: in std_logic;  
        BTNU: in std_logic ; --knop boven (spelerLinks omhoog/ kleinere waarde)
        BTNL: in std_logic ; --knop links (spelerLinks omlaag/grotere waarde)
        BTNR: in std_logic ; --knop rechts (spelerRechts omhoog/ kleinere waarde)
        BTND: in std_logic ; --knop beneden (spelerRechts omlaag/grotere waarde)
        slomo: in std_logic ; --slowmotion
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
     end component;
     
    component displayScore
    port(
        --in
       CLK25MHz: in std_logic;
       lWint: in std_logic;
       rWint: in std_logic;
       --out
       AN: out std_logic_vector(7 downto 0);--anodes        
       CA: out std_logic;--cathodes: actief ???
       CB: out std_logic;
       CC: out std_logic;
       CD: out std_logic;
       CE: out std_logic;
       CF: out std_logic;
       CG: out std_logic
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
        displayAan => displayAan,  
        hLocatie => hLocatie,
        vLocatie => vLocatie                           
        );
        
    spelers : PongSPeler
    Port map(
        --in
        CLK25MHz => CLK25MHz,
        BTNU => BTNU,
        BTNL => BTNL,
        BTNR => BTNR,
        BTND => BTND,
        slomo => slomo,
--        renderBal=>renderBal,
--        renderBorder => renderBorder,
--        renderLspeler => renderLspeler,
--        renderRspeler => renderRspeler,
        --out
        hBal=> hBal,
        vBal => vBal,
        spelerLinks => spelerLinks,
        spelerRechts => spelerRechts,
        lWint=>lWint,
        rWint=>rWint        
        );    
        
    score: displayScore
    port map(
            --in
       CLK25MHz=>CLK25MHZ,
       lWint=>lWint,
       rWint=>rWint,
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
    
    kleurGeven : process(--renderBal,renderLspeler,renderRspeler,renderBorder,
                            displayAan,hLocatie,vLocatie,spelerLinks,spelerRechts,vBal,hBal)
    begin
--        renderBal <= '0';
--        renderLspeler <= '0';
--        renderRspeler <='0';
--        renderBorder <= '0';
               
        if(displayAan = '1') then
            VGA_R <= "0000";--basiskleuren van het veld
            VGA_G <= "0111";
            VGA_B <= "0000";            
            
            if (vLocatie >= vBal and vLocatie < vBal+10 and hLocatie >= hBal and hLocatie < hBal+10) then-- het balletje 
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";   
--                renderBal <= '1';         
            end if;
            if(hLocatie<=5 or hLocatie >= 635)then--de borders aan de zijkant
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
--                renderBorder <='1';
            end if;
            if (vLocatie <= 5 or vLocatie >= 475) or (hLocatie >= 318 and hLocatie <= 322)then--de middellijn en de border vanboven en beneden
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
            end if;    
            if (hLocatie >5 and hLocatie<=10) and (vLocatie > spelerLinks and vLocatie<= spelerLinks + 50) then    
                VGA_R <= "1111";
                VGA_G <= "0000";
                VGA_B <= "0000";
--                renderLspeler <= '1';
            end if; 
            if (hLocatie >=630 and hLocatie<635) and (vLocatie > spelerRechts and vLocatie<= spelerRechts + 50) then    
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "0000";
--                renderRspeler <= '1';
            end if; 
        else --niks doorsturen tijdens de syncs/porches
            VGA_R <= "0000";
            VGA_G <= "0000";
            VGA_B <= "0000";                 
        end if;         
    end process;
    
end Behavioral;
