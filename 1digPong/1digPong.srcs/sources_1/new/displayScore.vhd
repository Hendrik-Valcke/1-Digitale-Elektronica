library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity displayScore is
   Port (
   --in
   CLK25MHz: in std_logic;
   scoreLinks: in integer range 0 to 100 := 0;
   scoreRechts: in integer range 0 to 100 := 0;
   slomo: in std_logic := '0';
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
end displayScore;

architecture Behavioral of displayScore is
signal klokTeller: integer range 0 to 15625000-1 := 0;
signal CLK800Hz : std_logic := '0';
signal displayTeller : integer range 0 to 8 := 0;
signal telLimiet: integer range 0 to 15625000;

signal tiental : std_logic := '0';
signal binGetal: unsigned(6 downto 0);
signal bcdTiental: unsigned(3 downto 0);
signal bcdEental: unsigned(3 downto 0);  
signal input: unsigned(3 downto 0); --ingangssignaal voor component
signal output : std_logic_vector(6 downto 0); --uitgangssignaal voor component
--componenten
    component BcdTo7Seg1Digitale--de converter van opgave 1, de namen van de in/out poorten komen overeen
    port (
        bcd : in unsigned(3 downto 0); --4 bits
        sevenSeg : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    --port map met component
    Converter : BcdTo7Seg1Digitale 
    port map( --poort van component => signaal
            bcd => input,
            sevenSeg => output
            );
    
    slowmotion: process(slomo)           
        begin                                
            if slomo = '1' then              
                telLimiet <= 15625000-1; --8Hz 
            else                             
                telLimiet <= 15625-1;--800Hz  
            end if;                          
        end process;                         
                                                                                 
    
    klokconverter: process(CLK25MHz)
    begin
        if rising_edge(CLK25MHz) then
            if klokteller >= telLimiet then --800Hz
                klokteller <= 0;
                CLK800Hz <= not(CLK800Hz);
            else
                klokteller <= klokteller + 1;
            end if;
        end if;                
    end process;

    displays: process(CLK800Hz)
    begin
        if rising_edge(CLK800Hz)then  
                case displayTeller is            
                    when 0 => AN <= (0=> '0', others =>'1');  --meest rechtse display
                            binGetal<=to_unsigned(scoreRechts,7);
                            --binGetal<=to_unsigned(scoreLinks,7);
                            tiental<= '0';
                            --input<= bcdEental;
                            displayTeller <= displayTeller + 1; 
                    when 1 => AN <= (1=> '0', others =>'1');
                            binGetal<=to_unsigned(scoreRechts,7);
                            tiental<= '1';
                            --input<= bcdTiental;
                            displayTeller <= displayTeller + 1; 
                    when 6 =>AN <= (6=> '0', others =>'1');
                            binGetal<=to_unsigned(scoreLinks,7);
                            --binGetal<=to_unsigned(scoreRechts,7);
                            tiental<= '0';
                            --input<= bcdEental;
                            displayTeller <= displayTeller + 1; 
                    when 7 =>AN <= (7=> '0', others =>'1'); -- meest linkse display
                            binGetal<=to_unsigned(scoreLinks,7);
                            tiental<= '1';
                            --input<= bcdTiental;
                            displayTeller <= 0;
                    when others => AN<="11111111"; 
                                displayTeller <= displayTeller + 1; 
                end case;
        end if;
    end process;
    
    scoreNaarBCD: process(binGetal)
    begin
        if binGetal >= 0 and binGetal <10 then
                bcdTiental <= "0000";--0x10
                bcdEental <= resize((binGetal),4);--van binGetal getal wordt het tiental afgtetrokken,dan ge'resize'd van 7 naar 4 bits
            elsif binGetal >= 10 and binGetal <20 then
                bcdTiental <= "0001";--1x10
                bcdEental <= resize((binGetal)-10,4);
            elsif binGetal >= 20 and binGetal <30 then
                bcdTiental <= "0010";--2x10
                bcdEental <= resize((binGetal)-20,4);
            elsif binGetal >= 30 and binGetal <40 then
                bcdTiental <= "0011";--3x10
                bcdEental <= resize((binGetal)-30,4);
            elsif binGetal >= 40 and binGetal <50 then
                bcdTiental <= "0100";--4x10
                bcdEental <= resize((binGetal)-40,4);                       
            elsif binGetal >= 50 and binGetal <60 then
                bcdTiental <= "0101";--5x10
                bcdEental <= resize((binGetal)-50,4);       
            elsif binGetal >= 60 and binGetal <70 then
                bcdTiental <= "0110";--6x10
                bcdEental <= resize((binGetal)-60,4);
            elsif binGetal >= 70 and binGetal <80 then
                bcdTiental <= "0111";--7x10
                bcdEental <= resize((binGetal)-70,4);    
            elsif binGetal >= 80 and binGetal <90 then
                bcdTiental <= "1000";--8x10
                bcdEental <= resize((binGetal)-80,4); 
            elsif binGetal >= 90 and binGetal <100 then
                bcdTiental <= "1001";--9x10
                bcdEental <= resize((binGetal)-90,4);                       
            else
                bcdTiental <= "1111";--regels van combinatorisch proces: altijd waarde toekennen!
                bcdEental <= "1111";
           end if;        
    end process;
    
    pInput : process(tiental, bcdEental, bcdTiental)
    begin
        if(tiental = '0')
        then
            input <= bcdEental;
        else
            input <= bcdTiental;          
        end if;
    end process;
    
    Invert : process(output) --de output van de converter (opgave1) naar de kathodes sturen
            begin
                --de nulwaarden van de converter moeten hier 1 zijn en andersom omdat de kathodes actief laag zijn
                CA <= not output(6);
                CB <= not output(5);
                CC <= not output(4);
                CD <= not output(3);
                CE <= not output(2);
                CF <= not output(1);
                CG <= not output(0);
            end process;            
    
end Behavioral;
