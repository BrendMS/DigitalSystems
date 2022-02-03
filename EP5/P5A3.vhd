library ieee;
use ieee.numeric_bit.all;

entity alucontrol is 
port(
    aluop: in bit_vector(1 downto 0);
    opcode: in bit_vector(10 downto 0);
    aluCtrl: out bit_vector(3 downto 0)
);
end entity;

architecture arch_AC of alucontrol is
    signal tipoR: bit_vector(3 downto 0);
    begin
        tipoR <= "0000" when opcode = "10001010000" else
                 "0010" when opcode = "10001011000" else        
                 "0110" when opcode = "11001011000" else
                 "0001";
        
        aluCtrl <= "0010" when aluop = "00" else
                   "0111" when aluop = "01" else
                   tipoR;

end architecture;