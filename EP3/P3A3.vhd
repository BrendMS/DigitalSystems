library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity reg is
generic(wordSize: natural := 4);
port(
    clock: in bit; 
    reset: in bit;
    load:  in bit;
    d:     in bit_vector(wordSize-1 downto 0);
    q:     out bit_vector(wordSize-1 downto 0)
);
end reg;

architecture arch_reg of reg is
    signal interno: bit_vector(wordSize-1 downto 0);
    begin
        process(clock, reset)
        begin
            if reset = '1' then 
                interno <= (others => '0'); 
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    interno <= d;
                end if;
            end if; 
        end process;
        q <= interno;
end architecture;

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

    type reg_tipo is array(regn-1 downto 0) of bit_vector(wordSize-1 downto 0);
    signal reg_vec : reg_tipo;
    
    type load_tipo is array(regn-1 downto 0) of bit;
    signal load_vec : load_tipo;

    signal int_rr1, int_rr2, int_wr: natural; 

    component reg is 
    generic(wordSize: natural := 4);
    port(
        clock: in bit; 
        reset: in bit;
        load:  in bit;
        d:     in bit_vector(wordSize-1 downto 0);
        q:     out bit_vector(wordSize-1 downto 0)
    );
    end component;

    begin

        Reg_gen : for i in 0 to regn - 1 generate
            load_vec(i) <= '1'  when i = to_integer(unsigned(wr)) and regWrite = '1' else
                            '0';

            regnulo: if i = regn-1 generate
                nulo: reg 
                generic map(wordSize)            
                port map(clock, reset, '0', d, reg_vec(i));
            end generate;

            regt: if i < regn-1 generate
                total: reg 
                generic map(wordSize)
                port map(clock, reset, load_vec(i), d, reg_vec(i));
            end generate;
        end generate;

        int_rr1 <= to_integer(unsigned(rr1));
        int_rr2 <= to_integer(unsigned(rr2));

        q1 <= reg_vec(int_rr1);

        q2 <= reg_vec(int_rr2);
               
end architecture;

------------------------------------ OPERACOES ------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity soma is
    port(
        x1, x2 : in bit_vector(15 downto 0);
        x0 : out bit_vector(15 downto 0)
    );

end soma;
architecture arch_soma of soma is
    signal vec : signed(15 downto 0);

    begin
        vec <= signed(x1) + signed(x2);
        x0 <= bit_vector(vec);
end architecture;

library ieee;
use ieee.numeric_bit.all;

entity sub is
    port(
        x1, x2 : in bit_vector(15 downto 0);
        x0 : out bit_vector(15 downto 0)
    );

end sub;

architecture arch_sub of sub is
    signal vec : signed(15 downto 0);

    begin
        vec <= signed(x1) - signed(x2);
        x0 <= bit_vector(vec);
end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity calc is 
    port(
        clock: in bit;
        reset: in bit;
        instruction: in bit_vector(16 downto 0);
        q1: out bit_vector(15 downto 0)
    );
end calc;

architecture arch_calc of calc is

----------- COMPONENTES  --------------------------------
    component regfile is
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
    end component;

    component soma is
        port(
            x1, x2 : in bit_vector(15 downto 0);
            x0 : out bit_vector(15 downto 0)
        );

    end component;

    component sub is
        port(
            x1, x2 : in bit_vector(15 downto 0);
            x0 : out bit_vector(15 downto 0)
        );

    end component;

-------- CALCULADORA ------------------------------------

    signal X0, XA, XS, vec, X1, X2, X3, S2 : bit_vector(15 downto 0);

    begin

        vec(15 downto 5) <= (others => instruction(14));
        vec(4 downto 0) <=  bit_vector(signed(instruction(14 downto 10)));

        RFA: regfile
        generic map(32, 16)
        port map(clock, reset, '1', instruction(9 downto 5), instruction(14 downto 10), 
                 instruction(4 downto 0), X0, X1, X2);

                   ------------ operacao -----------------

        ADD0: soma port map(X1, S2, XA);
        SUB0: sub port map(X1, S2, XS);

        X0 <= XA when (instruction(16 downto 15) = "00" or instruction(16 downto 15) = "01") else
              XS when (instruction(16 downto 15) = "10" or instruction(16 downto 15) = "11") ;

        S2 <= X2 when (instruction(16 downto 15) = "00" or instruction(16 downto 15) = "10") else
              vec when (instruction(16 downto 15) = "01" or instruction(16 downto 15) = "11") ;
            
        q1 <= X1; 

end architecture; 