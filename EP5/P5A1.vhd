library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port(
        i: in bit_vector(31 downto 0);
        o: out bit_vector(63 downto 0)
    );
end signExtend;

architecture arch_SE of signExtend is
    signal D, CB: bit_vector(1 downto 0);
    signal B: bit;

    begin
        B <= '0';
        D <= "11";
        CB <= "10";

        o <= ((63 downto 26 => i(25)) & i(25 downto 0)) when i(31) = B else
             ((63 downto 9 => i(20)) & i(20 downto 12)) when i(31 downto 30) = D else
             ((63 downto 19 => i(23)) & i(23 downto 5)) when i(31 downto 30) = CB;
        
end architecture;
