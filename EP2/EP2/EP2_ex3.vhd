library IEEE;
use IEEE.numeric_bit.all;
use std.textio.all;

entity rom_arquivo_generica is 
    generic(
        addressSize : natural := 5;
        wordSize : natural := 8;
        datFileName : string := "conteudo_rom_ativ_02_carga.dat"
    );
    port(
        addr: in bit_vector(addressSize-1 downto 0);
        data: out bit_vector(wordSize-1 downto 0)
    );

end rom_arquivo_generica;

architecture arch_RAG of rom_arquivo_generica is

    type mem_tipo is array(0 to (2**addressSize)-1) of bit_vector(wordSize-1 downto 0);

    impure function init_mem(file_name : in string) return mem_tipo is
        file file_handler : text open read_mode is file_name;
        variable row : line;
        variable temp_bv : bit_vector(wordSize-1 downto 0);
        variable temp_mem : mem_tipo;
    begin
        for i in mem_tipo'range loop
            readline(file_handler, row);
            read(row, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;
    end function;

    signal mem : mem_tipo := init_mem(datFileName);

    begin
        data <= mem(to_integer(unsigned(addr)));

end arch_RAG;
