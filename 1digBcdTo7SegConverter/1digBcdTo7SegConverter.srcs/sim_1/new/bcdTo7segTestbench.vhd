library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity bcdTo7segTestbench is
end bcdTo7segTestbench;

architecture Behavioral of bcdTo7segTestbench is --signalen definieren die voor controle zullen worden gebruikt

  signal InputVector : unsigned (3 downto 0);
  signal OutputVector: std_logic_vector(6 downto 0);

  component BcdTo7Seg1Digitale --zelfde poorten als de design
  port ( bcd:  in unsigned (3 downto 0);
           sevenSeg:  out std_logic_vector (6 downto 0)); 
  end component;

begin

  BcdTo7Seg1DigitaleDesign: BcdTo7Seg1Digitale port map( --bcdIn van design wordt inputvector in testbench enz..
    bcd => InputVector,
    sevenSeg => OutputVector);
  
  p_Stimuli: process
  
  begin
  
        InputVector <= "0000";--0
        wait for 10ns;
        if OutputVector /= "1111110" then --controle
            assert false 
            report "Het uitgangssignaal F is hier niet 1111110" --geeft warning in de tcl console
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "0001";--1
        wait for 10ns;
        if OutputVector /= "0110000" then
            assert false 
            report "Het uitgangssignaal F is hier niet 0110000" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "0010";--2
        wait for 10ns;
        if OutputVector /= "1101101" then
            assert false 
            report "Het uitgangssignaal F is hier niet 1101101" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "0011";--3
        wait for 10ns;
        if OutputVector /= "1111001" then
            assert false 
            report "Het uitgangssignaal F is hier niet 1111001" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "0100";--4
        wait for 10ns;
        if OutputVector /= "0110011" then
            assert false 
            report "Het uitgangssignaal F is hier niet 0110011" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "0101";--5
        wait for 10ns;
        if OutputVector /= "1011011" then
            assert false 
            report "Het uitgangssignaal F is hier niet 1011011" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "0110";--6
        wait for 10ns;
        if OutputVector /= "1011111" then
            assert false 
            report "Het uitgangssignaal F is hier niet 1011111" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "0111";--7
        wait for 10ns;
        if OutputVector /= "1110000" then
            assert false 
            report "Het uitgangssignaal F is hier niet 1110000" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "1000";--8
        wait for 10ns;
        if OutputVector /= "1111111" then
            assert false 
            report "Het uitgangssignaal F is hier niet 1111111" 
            severity warning;
        end if;
        wait for 90ns;
        
        InputVector <= "1001";--9
        wait for 10ns;
        if OutputVector /= "1111011" then
            assert false 
            report "Het uitgangssignaal F is hier niet 1111011" 
            severity warning;
        end if;
        wait for 90ns;
    
  end process p_Stimuli;
   
end Behavioral;
