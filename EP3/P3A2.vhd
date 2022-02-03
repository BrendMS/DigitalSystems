library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity regfile is
    generic(
        regn     : natural := 32;
        wordSize : natural := 64
    );
    port(
        clock        : in bit;
        reset        : in bit;
        regWrite     : in bit;
        rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
        d            : in bit_vector(wordSize - 1 downto 0);
        q1, q2       : out bit_vector(wordSize -1 downto 0)
    );
end regfile;

architecture arch_regf of regfile is

    type reg_tipo is array(regn-2 downto 0) of bit_vector(wordSize-1 downto 0);
    signal reg : reg_tipo;

    signal int_rr1, int_rr2, int_wr: natural; 

    begin
        process(clock, reset)
        begin
            if reset = '1' then 
                for i in 0 to regn-2 loop
                    reg(i)  <= (others => '0'); 
                end loop;

            elsif (clock'event and clock = '1' and regWrite = '1') then
                if int_wr < regn-1 then
                    reg(int_wr) <= d; 
                end if; 
            end if; 

        end process;

        int_wr <= to_integer(unsigned(wr));
        int_rr1 <= to_integer(unsigned(rr1));
        int_rr2 <= to_integer(unsigned(rr2));

        q1 <= (others => '0') when int_rr1 = regn -1 else
               reg(int_rr1);

        q2 <= (others => '0') when int_rr2 = regn -1 else
               reg(int_rr2);
               
end architecture;
