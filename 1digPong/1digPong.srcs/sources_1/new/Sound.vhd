
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sound is
    Port (
          --in
          CLK25MHZ: in std_logic := '0';
          winGeluid: in std_logic := '0';
          speelDeun: in std_logic := '0';
          --out
          AUD_PWM: out std_logic := '0'
        
     );
end Sound;

architecture Behavioral of Sound is
signal klokteller: integer range 0 to 25000 := 0; --500Hz
signal tuneTeller: integer range 0 to 12500000:= 0;
signal nootTeller: integer range 0 to 6;
signal freqTelLimiet:  integer range 0 to 25000000;
signal speelTune: std_logic := '0';
signal pwm : std_logic := '0';

begin
    
    deuntje: process(CLK25MHz)--speelt de tonen D E F G E C D 
    begin
        if rising_edge(CLK25MHz)then
            if speelDeun = '1' then            
                if winGeluid = '1' then
                    speelTune <= '1';
                end if;
                if tuneTeller >= 12500000 and speelTune = '1' then -- halve seconde
                    tuneTeller <= 0;
                    nootTeller <= nootTeller +1;
                    case nootTeller is
                                when 0 =>  freqTelLimiet <= 42662;--D 293 HZ
                                when 1 => freqTelLimiet <=37878;--E 330 Hz
                                when 2 => freqTelLimiet <=35714;--F 350 Hz
                                when 3 => freqTelLimiet <=31887;--G 392 Hz
                                when 4 => freqTelLimiet <=37878;--E 330Hz 
                                when 5 => freqTelLimiet <=47709;--C 262 Hz
                                when 6 => freqTelLimiet <= 42662;-- D 293 Hz
                                when others => nootTeller <= 0;
                                            speelTune <= '0';
                                            freqTelLimiet <= 2500-1;
                            end case;
                else
                    tuneTeller <= tuneTeller +1;
                end if;
           end if; 
        end if;
    end process;
    
--    noot:process(nootTeller)
--    begin
--        case nootTeller is
--            when 0 =>  freqTelLimiet <= 42662;--D 293 HZ
--            when 1 => freqTelLimiet <=37878;--E 330 Hz
--            when 2 => freqTelLimiet <=35714;--F 350 Hz
--            when 3 => freqTelLimiet <=31887;--G 392 Hz
--            when 4 => freqTelLimiet <=37878;--E 330Hz 
--            when 5 => freqTelLimiet <=47709;--C 262 Hz
--            when 6 => freqTelLimiet <= 42662;-- D 293 Hz
--            when others => nootTeller <= 0;
--                        speelTune <= '0';
--                        freqTelLimiet <= 2500-1;
--        end case;
--    end process;

    klok: process(CLK25MHZ)
    begin
        if rising_edge(CLK25MHz) then
            if klokteller < freqTelLimiet then
                klokteller <= klokteller +1;
                
            else
                klokteller <= 0;
                pwm<= not(pwm);
            end if;
        end if;
    end process;
    
    poorten: process(pwm)
    begin
        aud_pwm<= pwm;
    end process;



end Behavioral;
