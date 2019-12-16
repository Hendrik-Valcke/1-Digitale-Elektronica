library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity BcdTo7Seg1Digitale is
    Port (
    bcd: in unsigned(3 downto 0); --bcd in 4 bits
    sevenSeg: out std_logic_vector(6 downto 0) --7segment in vectorvorm (abcdefg) met 7 elementen
    );
end BcdTo7Seg1Digitale;

architecture RTL of BcdTo7Seg1Digitale is 
    type sevenSegArray is array(0 to 9) of std_logic_vector(6 downto 0);-- een type array met 10 elementen waarvan elk element een std_logic vector is met 7 elementen
    constant constantSevenSeg: sevenSegArray:= --een array waarvan het n-de element overeenstemt met de 7-segment code
    ( "1111110", --0 
      "0110000", --1
      "1101101", --2
      "1111001", --3
      "0110011", --4
      "1011011", --5
      "1011111", --6
      "1110000", --7
      "1111111", --8
      "1111011"); --9
      
begin
Conversie: process (bcd)--de commentaren met een ** voor zijn hier voorbereiding op een volgende oefening
    begin
        if bcd < 10 -- checken of het wel op 1 display past dus voor 0 t.e.m. 9
        then
        sevenSeg <= constantSevenSeg(TO_INTEGER(unsigned(bcd))); --converteer bcd n naar integer en neem n-de element van de array
        else sevenSeg <= "1001111"; -- de E van error
        end if;
    end process Conversie;

end RTL;
