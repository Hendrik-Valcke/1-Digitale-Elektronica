--Als DIP switch SW0
--  gelijk is aan 0 => Beschouw SW15-12 en SW11-8 als positief binaire getallen
--  gelijk is aan 1 => Beschouw SW15-12 en SW11-8 als two's complement getallen
--Laat het product van deze getallen zien op LED15-8
--Gebruik als ingangen enkel integers.

--DISCLAIMER: deze opgave moet nog nagekeken worden, vertrouw er niet op dat ze klopt!
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity fourBit2sComplementVermenigvuldiger is
    Port (
          --in
          intL : in integer range 0 to 15; --switch 15-12, een range van 16: dus 4 bits
          intR : in integer range 0 to 15; --switch 11-8
          twosCompMode: in integer range 0 to 1; --SW0 --gewoon optellen bij 0, 2's complement bij 1
          --out
          LED : out integer range 0 to 255 --actief hoog, led 15 tot 8, een range van 256 dus 8 bits
          );
end fourBit2sComplementVermenigvuldiger;

architecture Behavioral of fourBit2sComplementVermenigvuldiger is
begin

    vermenigvuldiging: process(intL,intR,twosCompMode)    
    begin
        if twosCompMode = 0 then
            LED <= intL*intR;
        else --twosCompMode = '1'
            if intL >= 8 and intR >= 8 then -- groter dan 8 (1000) dus de tekenbit is 1=> negatief bij intL en intR
                LED <= (intL -16)*(intR-16);
            elsif intL >= 8 and intR < 8 then --intL is negatief en intR postief
                LED <= (intL -16)*intR;
            elsif intL < 8 and intR >= 8 then --intL is positief en intR negatief
                LED <= intL*(intR-16);
            else --waarde voor de zekerheid
                LED <= 0;
            end if;            
            
        end if;
     end process;

end Behavioral;
