library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AI is
    Port (
            --in
            CLK25MHz: in std_logic := '0';
            AImode: in std_logic := '0';
            --hBal: in integer range 0 to 640;
            vBal: in integer range 0 to 480;
            spelerRechts: in integer range 0 to 480;
            rSpelerLengte: in integer range 0 to 70;
            --out
            rUp: out std_logic := '0';
            rDown: out std_logic := '0'
         );
end AI;

architecture Behavioral of AI is
signal klokteller: integer range 0 to 1250000 := 0;

begin

    palletBesturen: process(CLK25MHZ)
    begin
        if rising_edge(CLK25MHZ) then
            if klokteller >= 1250000-1 then
                klokteller <=  0;
                if AImode = '1' then
                    rUp <= '0';
                    rDown <= '0';
                    if vBal+10 > spelerRechts + rSpelerLengte  then
                        rDown <= '1';
                    elsif vBal < spelerRechts then
                        rUp <= '1';
                    end if;
                end if;
            else 
                klokteller <= klokteller +1;
            end if;
        end if;
    end process;

end Behavioral;
