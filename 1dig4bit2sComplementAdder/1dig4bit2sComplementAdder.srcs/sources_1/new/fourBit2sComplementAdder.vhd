--Als DIP switch SW0
--  gelijk is aan 0 => Beschouw SW15-12 en SW11-8 als positief binaire getallen
--  gelijk is aan 1 => Beschouw SW15-12 en SW11-8 als two's complement getallen
--Laat de som van deze getallen zien op LED15-11
--Als DIP switch SW1
--  gelijk is aan 0 => Gebruik LED15-11, zodat er nooit overflow kan optreden
--  gelijk is aan 1 => Gebruik LED14-11 (LED15=uit) en doe aan "wrap around"

-- DISCLAIMER: 2's complement moet nog nagekeken worden, vertrouw er niet op dat dit klopt

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

begin

    optelling: process(binL,binR,overflowMode,twosCompMode)
    begin
        if overflowMode = '0' then --extra bit toevoegen vanvoor
            if twosCompMode = '0' then --gewoon optellen
                LED <= std_logic_vector(resize(binL,5) + resize(binR,5)); 
            else --twosCompMode = '1'           
                LED <= std_logic_vector(resize(not(binL)+1,5) + resize(not(binR)+1,5));
            end if;
        else --overflowMode = '1' dus 4 bits gebruiken, 5de bit '0' geven
            if twosCompMode = '0' then --gewoon optellen
                LED <= '0' & std_logic_vector(binL + binR); 
            else --2's complement
                LED <= '0' & std_logic_vector((not(binL)+1)+(not(binR)+1));
            end if;
        end if;
    end process;


end Behavioral;
