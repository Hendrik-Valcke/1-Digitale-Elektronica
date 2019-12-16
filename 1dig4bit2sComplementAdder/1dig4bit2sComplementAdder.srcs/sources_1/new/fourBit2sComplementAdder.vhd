--Als DIP switch SW0
--  gelijk is aan 0 => Beschouw SW15-12 en SW11-8 als positief binaire getallen
--  gelijk is aan 1 => Beschouw SW15-12 en SW11-8 als two's complement getallen
--Laat de som van deze getallen zien op LED15-11
--Als DIP switch SW1
--  gelijk is aan 0 => Gebruik LED15-11, zodat er nooit overflow kan optreden
--  gelijk is aan 1 => Gebruik LED14-11 (LED15=uit) en doe aan "wrap around"

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity fourBit2sComplementAdder is
  Port ( 
        --in
        binL : in unsigned(3 downto 0); --switch 15-12
        binR : in unsigned(3 downto 0); --switch 11-8
        twosCompMode: in std_logic; --SW0 --gewoon optellen bij 0, 2's complement bij 1
        overflowMode: in std_logic; --SW1: overflow bij 1
        
        --out
        LED : out std_logic_vector(4 downto 0)--actief hoog
        );
end fourBit2sComplementAdder;

architecture Behavioral of fourBit2sComplementAdder is
--signalen
signal intL,intR : integer;

begin

    optelling: process(intL,intR,binL,binR,overflowMode,twosCompMode)
    begin
        LED <= "00000";--standaardwaarden om latches te vermijden
        intL <= 0;
        intR <= 0;
        if overflowMode = '0' then --extra bit toevoegen vanvoor
            if twosCompMode = '0' then --gewoon optellen
                LED <= std_logic_vector(resize(binL,5) + resize(binR,5)); 
            else --twosCompMode = '1' 
                if binL >= 8 then
                    intL <= to_integer(binL) - 16;
                else
                    intL <= to_integer(binL);
                end if;
                if binR >= 8 then
                    intR <= to_integer(binR) - 16;
                else
                    intR <= to_integer(binR);
                end if;
                if intl+intR<0 then
                    LED <= '1' & std_logic_vector(resize(resize(binL,5) + resize(binR,5),4)); 
                else
                    LED <= '0' & std_logic_vector(resize(resize(binL,5) + resize(binR,5),4)); 
                end if;
            end if;
        else --overflowMode = '1' dus 4 bits gebruiken, 5de bit '0' geven
            if twosCompMode = '0' then --gewoon optellen
                LED <= '0' & std_logic_vector(binL + binR); 
            else --twosCompMode = '1' 
                LED <= '0' & std_logic_vector(binL + binR);
            end if;            
        end if;
    end process;


end Behavioral;
