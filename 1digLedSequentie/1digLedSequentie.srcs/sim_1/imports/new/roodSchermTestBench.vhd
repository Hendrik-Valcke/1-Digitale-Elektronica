library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity roodSchermTestBench is
--  Port ( );
end roodSchermTestBench;

architecture Behavioral of roodSchermTestBench is
signal clock : std_logic := '0';
signal reset : std_logic := '0';
    component LedSequenties
    Port(
        --in
            CLK100MHZ: in std_logic; -- de 100MHz klok van het bordje zelf, deze kan je niet aanpassen
            reset : in std_logic; --BTNC in 
            --out
            LED: out std_logic_vector(15 downto 0) --LED 15 staat links, LED 0 rechts
            );
    end component; 
                      
begin
    
    pReset: process
    begin
        wait for 1000000000ns;--2sec
        reset <= '1';
        wait for 5000000ns;--50µs
        reset <= '0';
    end process;

    klok: LedSequenties
    port map(
            CLK100MHz=>clock,
            reset => reset
            );
    pClock : process
           begin
               clock <= not clock;
               wait for 5ns;
           end process;

end Behavioral;
