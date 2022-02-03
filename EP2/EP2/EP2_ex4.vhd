library IEEE;
use IEEE.numeric_bit.all;

entity ram is 
    generic(
        addressSize : natural := 5;
        wordSize : natural := 8
    );
    port(
        ck, wr : in bit;
        addr: in bit_vector(addressSize-1 downto 0);
        data_i: in bit_vector(wordSize-1 downto 0);
        data_o: out bit_vector(wordSize-1 downto 0)
    );

end ram;

architecture arch_RAM of ram is

    type mem_tipo is array(0 to (2**addressSize)-1) of bit_vector(wordSize-1 downto 0);

    signal mem : mem_tipo;
    signal address : bit_vector(addressSize-1 downto 0);

    begin
        process(ck) is
            begin
                if (wr = '1' and ck'EVENT and ck='1') then
                    mem(to_integer(unsigned(addr))) <= data_i;
                end if;
        end process;

        data_o <= mem(to_integer(unsigned(addr)));
        
end arch_RAM;