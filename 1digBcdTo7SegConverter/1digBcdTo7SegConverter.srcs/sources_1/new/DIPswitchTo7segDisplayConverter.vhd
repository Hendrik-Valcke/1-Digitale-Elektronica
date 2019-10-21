library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

--commentaar met ** betekent dat het in een latere opgave gebruikt zal worden
entity DIPswitchTo7segDisplayConverter is
    Port (
    SW : in std_logic_vector(15 DOWNTO 0);--de 16 switches (vector): gaat van links:15 naar rechts:0 (regel 12-27 in constraint)
    AN : out std_logic_vector(7 downto 0);--anodes van de 8 7seg displays (vector) (regel 66-73 in constraint)
        
    --**BTNC : in std_logic; --knop: actief hoog (regel 77 in constraint)
        
    --**DP : out std_logic;--decimal point (regel 64 in constraint)
        
    CA : out std_logic;--cathodes: 1 cathode voor alle 7 LED-elementen per 7segment display (regel 56-62 in constraint)
    CB : out std_logic;
    CC : out std_logic;
    CD : out std_logic;
    CE : out std_logic;
    CF : out std_logic;
    CG : out std_logic
    );
end DIPswitchTo7segDisplayConverter;

architecture Behavioral of DIPswitchTo7segDisplayConverter is 

    component BcdTo7Seg1Digitale--de converter van opgave 1, de namen van de in/out poorten komen overeen
        port (
        bcd : in unsigned(3 downto 0); --4 bits
        sevenSeg : out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal binair : unsigned(6 downto 0); --7 bits want we gebruiken 7 switches per getal, dus een 7 bit binair getal
    signal input: unsigned(3 downto 0);
    signal output : std_logic_vector(6 downto 0);
    signal bcdTiental: unsigned(3 downto 0);
    signal bcdEental: unsigned(3 downto 0);
    
    
    

begin
    Converter : BcdTo7Seg1Digitale port map( --poort van component => signaal
                                            bcd => input,
                                            sevenSeg => output
                                            );

    Invert : process(output)
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
        
    Displays: process(SW,bcdEental,bcdTiental)
    begin  
    
        -- de middelste switches (8 en 7) bepalen welke displays moeten branden 
            if SW(8) = '1' and SW(7) = '1'--dus de switches staan op 1 en 1
            then AN(0)<='0'; --meest rechtse display is dan aan    
                 AN(1)<='1';
                 AN(6)<='1';
                 AN(7)<='1';
                 binair <= unsigned(SW(6 downto 0));--input wordt gegeven door de rechtse 7 switches
                 input <= bcdEental; 
                 
            elsif SW(8) = '1' and SW(7) = '0'--dus de switches staan op 1 en 0
            then AN(0)<='1';  
                 AN(1)<='0'; --tweede-rechtse display is dan aan
                 AN(6)<='1';
                 AN(7)<='1';
                 binair <= unsigned(SW(6 downto 0));--input wordt gegeven door de rechtse 7 switches
                 input <= bcdTiental;
            
            elsif SW(8)='0' and SW(7)='1'--dus de switches staan op 0 en 1
            then AN(0)<='1';    
                 AN(1)<='1';
                 AN(6)<='0'; --tweede linkse display is dan aan
                 AN(7)<='1';
                 binair <= unsigned(SW(15 downto 9));--input wordt gegeven door de linkse 7 switches
                 input <= bcdEental;
                    
            elsif SW(7)= '0' and SW(8)= '0'--dus de switches staan op 0 en 0
            then AN(0)<='1';
                 AN(1)<='1';
                 AN(6)<='1';
                 AN(7)<='0'; --meest linkse display is dan aan 
                 binair <= unsigned(SW(15 downto 9));--input wordt gegeven door de linkse 7 switches
                 input <= bcdTiental;
            else                  
                 binair <= "1111111";--regels van combinatorisch proces: altijd waarde toekennen!
                 input <= bcdTiental;
            end if;            
            
            -- de ongebruikte displays uitzetten:
            AN(2) <= '1'; -- ze zijn actief laag
            AN(3) <= '1';
            AN(4) <= '1';
            AN(5) <= '1';
            --**DP <= '1';
    end process;
    
    binToBCD: process(binair)--tientallen worden manueel een waarde gegeven en de eentallen krijgen de waarde van het getal min  het tiental
    begin
        if binair >= 0 and binair <10 then
            bcdTiental <= "0000";--0x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair)),4);--binair getal wordt omgevormd naar integer, van dit integer wordt het tiental afgtetrokken, van de uitkomst wordt terug een unsigned gemaakt
        elsif binair >= 10 and binair <20 then
            bcdTiental <= "0001";--1x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-10,4);
        elsif binair >= 20 and binair <30 then
            bcdTiental <= "0010";--2x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-20,4);
        elsif binair >= 30 and binair <40 then
            bcdTiental <= "0011";--3x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-30,4);
        elsif binair >= 40 and binair <50 then
            bcdTiental <= "0100";--4x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-40,4);                       
        elsif binair >= 50 and binair <60 then
            bcdTiental <= "0101";--5x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-50,4);       
        elsif binair >= 60 and binair <70 then
            bcdTiental <= "0110";--6x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-60,4);
        elsif binair >= 70 and binair <80 then
            bcdTiental <= "0111";--7x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-70,4);    
        elsif binair >= 80 and binair <90 then
            bcdTiental <= "1000";--8x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-80,4); 
        elsif binair >= 90 and binair <100 then
            bcdTiental <= "1001";--9x10
            bcdEental <= to_unsigned(to_integer(unsigned(binair))-90,4);                       
       else
       bcdTiental <= "1111";--regels van combinatorisch proces: altijd waarde toekennen!
       bcdEental <= "1111";
       end if;
       
    end process;
    
end Behavioral;
