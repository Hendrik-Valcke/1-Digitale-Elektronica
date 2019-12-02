library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity roodSchermTestBench is
--  Port ( );
end roodSchermTestBench;

architecture Behavioral of roodSchermTestBench is
signal clock : std_logic := '0';
    component RoodVgaScherm
    Port(
        CLK100MHZ: in std_logic :='0'; -- de 100MHz klok van het bordje zelf, deze kan je niet aanpassen
            --out
            VGA_R: out std_logic_vector(3 downto 0);
            VGA_G: out std_logic_vector(3 downto 0);
            VGA_B: out std_logic_vector(3 downto 0);
            VGA_HS : out std_logic;
            VGA_VS : out std_logic
            );
    end component; 
                      
begin

    klok: RoodVgaScherm
    port map(
            CLK100MHz=>clock
            );
    pClock : process
           begin
               clock <= not clock;
               wait for 5ns;
           end process;

end Behavioral;
