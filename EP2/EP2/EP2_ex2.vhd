library IEEE;
use IEEE.numeric_bit.all;
use std.textio.all;

entity rom_arquivo is 
    port(
        addr: in bit_vector(4 downto 0);
        data: out bit_vector(7 downto 0)
    );
end rom_arquivo;

architecture arch_RA of rom_arquivo is

    type mem_tipo is array(0 to 31) of bit_vector(7 downto 0);

    impure function init_mem(file_name : in string) return mem_tipo is
        file file_handler : text open read_mode is file_name;
        variable row : line;
        variable temp_bv : bit_vector(7 downto 0);
        variable temp_mem : mem_tipo;
    begin
        for i in mem_tipo'range loop
            readline(file_handler, row);
            read(row, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;
    end function;

    signal mem : mem_tipo := init_mem("conteudo_rom_ativ_02_carga.dat");

    begin
        data <= mem(to_integer(unsigned(addr)));

end arch_RA;
