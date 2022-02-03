entity fulladder is
    port (
      a, b, cin: in bit;
      s, cout: out bit
    );
   end entity;

architecture structural of fulladder is
    signal axorb: bit;
  begin
    axorb <= a xor b;
    s <= axorb xor cin;
    cout <= (axorb and cin) or (a and b);
   end architecture;
   
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
                  b when operation = "11" ;
        

end architecture;

library ieee;
use ieee.numeric_bit.all;

entity alu is
    generic (
        size : natural := 10 -- bit size
    );
    port    (
        A, B  : in  bit_vector(size-1 downto 0); -- inputs
        F     : out bit_vector(size-1 downto 0); -- outputs
        S     : in  bit_vector(3 downto 0); --op selection
        Z     : out bit; --zero flag
        Ov    : out bit; --overflow flag
        Co    : out bit --carry out flag
    );
end entity alu;

architecture arch_alu of alu is 
    component alu1bit is
        port(
            a, b, less, cin: in bit;
            result, cout, set, overflow: out bit;
            ainvert, binvert: in bit;
            operation: in bit_vector(1 downto 0)
        );
    end component;

    signal cout_vec: bit_vector(size-2 downto 0);
    signal rsoma_vec, overflow_vec, set_vec, slt_vec, z_comp : bit_vector(size-1 downto 0);
    signal opcode: bit_vector (1 downto 0);
    signal c, ainvert, binvert: bit;

    begin
        --------- internos -----------------
    
        ainvert <= S(3);
        binvert <= S(2);
         
        z_comp <= (others=>'0') ;

        slt_vec <= bit_vector(to_unsigned(1, size)) when signed(A) < signed(B) else
                   bit_vector(to_unsigned(0, size));
        
        opcode <= S(1) & S(0);

        c <= binvert;
        --------- maps ---------------------

        A1: alu1bit 
        port map (A(0), B(0), slt_vec(0), c, rsoma_vec(0), cout_vec(0), set_vec(0), overflow_vec(0), ainvert, binvert, opcode);

        A32: alu1bit 
        port map (A(size-1), B(size-1), slt_vec(size - 1), cout_vec(size-2), rsoma_vec(size-1), Co, set_vec(size-1), overflow_vec(size-1), ainvert, binvert, opcode);

        G1: for i in 1 to size-2 generate
               alu1bit0: alu1bit 
               port map (A(i), B(i), slt_vec(0), cout_vec(i-1), rsoma_vec(i), cout_vec(i), set_vec(i), overflow_vec(i), ainvert, binvert, opcode);
        end generate;

        ------- saidas ----------------------

        F <= rsoma_vec when not(S = "0111") else
             B; 
        
        Z <= '1' when rsoma_vec = z_comp else
            '0';

        Ov <= overflow_vec(size -1); 
        
end architecture;