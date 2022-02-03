library ieee;
use ieee.numeric_bit.all;

entity controlunit is
    port(
        -- to datapath
        reg2loc: out bit;
        uncondBranch: out bit;
        branch: out bit;
        memRead: out bit;
        memToReg: out bit;
        aluOp: out bit_vector(1 downto 0);
        memWrite: out bit;
        aluSrc: out bit;
        regWrite: out bit;
        -- from datapath
        opcode: in bit_vector(10 downto 0)
    );
end entity;

architecture arch_CrtlUni of controlunit is

    begin

        reg2loc <= opcode(7);
        uncondBranch <= not opcode(10);
        branch <= opcode(5);
        memToReg <= opcode(1);
        aluOp <= opcode(4) & opcode(5);

        memWrite <= opcode(10) and opcode(9) and (not opcode(1) and opcode(7));

        memRead <= opcode(1) when opcode(5)  = '0' else
                   '0';  

        aluSrc <= opcode(9) when opcode(7) = '1' else
                  '0';

        regWrite <= (opcode(10) and opcode(9) and opcode(1)) or (not opcode(7));
        
end architecture;
    
        

    


