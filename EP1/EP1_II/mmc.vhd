--------- Unidade de Controle -------------------
entity uni_ctr is
    port(
        clock, reset, iniciar: in bit;
        menor, dif, zero: in bit; 
        x1, x2, s1, s2, fim: out bit
    );
end entity;

architecture arch_UC of uni_ctr is
    type state_type is (espera, comp_a_b, b_menor_a, b_maior_a, igual);
    signal present_state, next_state : state_type;

begin

    process(clock, reset)
    begin
        if reset = '1' then	-- reset assincrono
            present_state <= espera;		
        elsif (clock'event and clock = '1') then	
            present_state <= next_state;
        end if;
    end process;


    next_state <= comp_a_b when (present_state = espera) and (iniciar = '1') and (zero = '0') else
                  espera when (present_state = igual) or ((present_state = espera) and (iniciar = '0') and (zero = '0')) else 
                      
                  igual when ((present_state = comp_a_b) and (dif = '0')) or (zero = '1') else              
                  b_menor_a when (present_state = comp_a_b) and (dif = '1') and (menor = '1') and (zero = '0') else
                  b_maior_a when (present_state = comp_a_b) and (dif = '1') and (menor = '0') and (zero = '0') else
    

                  comp_a_b when (present_state = b_menor_a) or (present_state = b_maior_a);
                     

    x1 <= '1' when (present_state = espera) else '0';
    x2 <= '1' when (present_state = igual) else '0';   

    s1 <= '1' when (present_state = b_maior_a) else '0';
    s2 <= '1' when (present_state = b_menor_a) else '0';

    fim   <= '1' when (present_state = igual) else '0';

end arch_UC;

-------------- fluxo de dados ----------------------------
library IEEE;
use IEEE.numeric_bit.all;

entity flux_dados is 
    port(
        x1, x2, s1, s2: in bit;        
        a, b: in bit_vector(7 downto 0);
        dif, menor, zero: out bit; 
        soma: out bit_vector(8 downto 0);
        MMC_out: out bit_vector(15 downto 0)
    );
end entity;

architecture arch_FD of flux_dados is

    signal  soma_ent, soma_s: unsigned(8 downto 0);    
    signal mA_ent, mA_s, mB_ent, mB_s: unsigned(15 downto 0);
    signal mA, mB: bit_vector(7 downto 0);
    signal zerou: bit;

begin
    mA <= a when (x1 = '1');
    mB <= b when (x1 = '1');   

    mA_ent <= (unsigned("00000000" & mA) + unsigned(mA_s)) when (s1 = '0');

    mB_ent <= (unsigned("00000000" & mB) + unsigned(mB_s)) when (s2 = '0');

    mA_s <=  mA_ent when (s1 = '1') and (s2 = '0') else
            (unsigned("00000000" & A)) when (x1 = '1');

    mB_s <= mB_ent when (s2 = '1') and (s1 = '0' ) else
            (unsigned("00000000" & B)) when (x1 = '1');


    soma_ent <= (soma_s + "000000001") when ((s1 = '1') or (s2 = '1')) else
                "000000000" when (x1 = '1') or (zerou = '1');

    soma_s <= (soma_ent) when ((s1 = '0') and (s2 = '0')) else
                "000000000" when (x1 = '1') or (zerou = '1');


    MMC_out <= bit_vector(mA_s) when (x2 ='1') and (zerou = '0') else 
           "0000000000000000";

    soma <= bit_vector(soma_s) when (x2 ='1') and (zerou = '0') else 
              "000000000"; 


    dif <= '1' when (mA_s /= mB_s) else '0';

    menor <= '1' when (mB_s < mA_s) else '0';

    zero <= '1' when (x1 = '0') and ((mA_s = "0000000000000000") or (mB_s = "0000000000000000")) else '0';
    zerou <= '1' when (x1 = '0') and ((mA_s = "0000000000000000") or (mB_s = "0000000000000000")) else '0';


end arch_FD;

------------------------ MMC ----------------------------------

library IEEE;
use IEEE.numeric_bit.all;

entity mmc is    
    port(
        reset, clock: in bit;
        inicia: in bit;
        A, B: in bit_vector(7 downto 0);
        fim: out bit;
        nSomas: out bit_vector(8 downto 0);
        MMC: out bit_vector(15 downto 0)
    );
end mmc;



architecture arch_mmc of mmc is

    component uni_ctr is
        port(
            clock, reset, iniciar: in bit;
            menor, dif, zero: in bit; 
            x1, x2, s1, s2, fim: out bit
        );
    end component;

    component flux_dados is 
        port(
            x1, x2, s1, s2: in bit;        
            a, b: in bit_vector(7 downto 0);
            dif, menor, zero: out bit; 
            soma: out bit_vector(8 downto 0);
            MMC_out: out bit_vector(15 downto 0)
        );
    end component;


    signal dif, menor, zero, s1, s2, x1, x2, clkNot: bit;

begin 
    clkNot <= not(clock);
    UC: uni_ctr port map( clock, reset, inicia, menor, dif, zero, x1, x2, s1, s2, fim);

    FD: flux_dados port map(x1, x2, s1, s2, A, B, dif, menor, zero, nSomas, MMC);

end architecture;

    
    

