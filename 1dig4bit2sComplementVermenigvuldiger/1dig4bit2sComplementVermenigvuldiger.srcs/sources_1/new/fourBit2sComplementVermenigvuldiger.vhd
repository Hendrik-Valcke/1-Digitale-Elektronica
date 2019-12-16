--Als DIP switch SW0
--  gelijk is aan 0 => Beschouw SW15-12 en SW11-8 als positief binaire getallen
--  gelijk is aan 1 => Beschouw SW15-12 en SW11-8 als two's complement getallen
--Laat het product van deze getallen zien op LED15-8
--Gebruik als ingangen enkel integers.

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
--signalen
signal lGetal: integer range -8 to 16;
signal rGetal: integer range -8 to 16;

begin

    vermenigvuldiging: process(lGetal,rGetal,intL,intR,twosCompMode)    
    begin
        if twosCompMode = 0 then
            LED <= intL*intR;
            lGetal<= 0;
            rGetal <= 0;
        elsif (twosCompMode = 1) then --twosCompMode = '1'
            if intL>= 8 then
                lGetal <= intL-16;
            else 
                lGetal <= intL;
            end if;
            if intR>= 8 then
                rGetal <= intR-16;
            else 
                rGetal <= intR;
            end if;
            if lGetal*rGetal <0 then
                LED<=to_integer(not(to_unsigned((abs(lGetal*rGetal)-1),8)));
            else
                LED <= lGetal*rGetal;
            end if;           
        else
            LED<=0; 
            lGetal<= 0;
            rGetal <= 0;
        end if;
     end process;

end Behavioral;
