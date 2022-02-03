entity alu1bit is
    port(
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
end entity;

architecture arch_alu1 of alu1bit is
    signal a_int, b_int, cout_int, r_soma : bit;

    component fulladder is
        port (
          a, b, cin: in bit;
          s, cout: out bit
        );
    end component;

    begin

        a_int <= a when ainvert = '0' else
                 not(a);
        b_int <= b when binvert = '0' else
                 not(b);    

        Soma: fulladder port map(a_int, b_int, cin, r_soma, cout_int);
        
        ----- saidas ----------
        overflow <= cin xor cout_int;
        cout <= cout_int;
        set <=  r_soma;

        result <= (a_int and b_int) when operation = "00" else
                  (a_int  or b_int) when operation = "01" else
                  r_soma when operation = "10" else
                  less when operation = "11" ;
        

end architecture;