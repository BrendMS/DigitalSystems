entity register6 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        parallel_in:  in  bit_vector(5 downto 0);
        parallel_out: out bit_vector(5 downto 0)
    );
end entity;

architecture arch_reg of register6 is
    signal internal: bit_vector(5 downto 0);
    begin
        process(clock, reset)
        begin
            if reset = '1' then -- reset assincrono
                internal <= (others => '0'); -- "000000"
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    internal <= parallel_in;
                end if;
            end if; 
        end process;
        parallel_out <= internal;
end architecture;

---------- Unidade de Controle ---------

entity UC is
    port(
        -- Sinais de controle global
        clock, reset: in bit;
        -- Entrada de controle
        iniciar: in bit;
        -- Sinais de status
        diferente, maior: in bit;
        -- Sinais de controle 
        h1, h2, s1, s2, x1: out bit;
        -- Saida de controle
        fim: out bit
    );
end entity;

architecture arch_UC of UC is

    type state is (espera, tes_a_b, a_igl_b, a_maior_b, a_menor_b);
    signal next_state, current_state: state;

    begin
        process(clock, reset)
        begin
            if reset = '1' then	-- reset assincrono
                current_state <= espera;		
            elsif (clock'event and clock = '1') then	
                current_state <= next_state;
            end if;
        end process;

    -- Logica de proximo estado
    next_state <= tes_a_b when (current_state = espera) and (iniciar = '1') else
                  espera when (current_state = espera) and (iniciar = '0') else
                      
                  a_igl_b when (current_state = tes_a_b) and (diferente = '0') else
                  a_maior_b when (current_state = tes_a_b) and (diferente = '1') and (maior = '1') else
                  a_menor_b when (current_state = tes_a_b) and (diferente = '1') and (maior = '0') else

                  tes_a_b when (current_state = a_maior_b) else
                  tes_a_b when (current_state = a_menor_b);

    -- Decodifica o estado para gerar sinais de controle
    h1 <= '1' when (current_state = espera) or (current_state = a_maior_b) else '0';
    h2 <= '1' when (current_state = espera) or (current_state = a_menor_b) else '0';
    s1 <= '1' when (current_state = a_maior_b) else '0';
    s2 <= '1' when (current_state = a_menor_b) else '0';
    
    fim <= '1' when (current_state = a_igl_b) else '0';
    x1 <= '1' when (current_state = a_igl_b) else '0';
    
end architecture;

---------- Fluxo de Dados ------------
library ieee;
use ieee.numeric_bit.all;

entity FD is
    port(
        -- Sinais de controle global
        clock: in bit;
        -- Sinais de controle da UC
        h1, h2, s1, s2, x1: in bit;
        -- Sinais de status
        diferente, maior: out bit; 
        -- Entrada de dados
        a_en, b_en: in bit_vector(5 downto 0);
        -- Entrada de controle 
        iniciar: in bit;
        -- Saida de dados
        mdc: out bit_vector(5 downto 0)

    );
end entity;

architecture arch_FD of FD is
    component register6 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            parallel_in:  in  bit_vector(5 downto 0);
            parallel_out: out bit_vector(5 downto 0)
        );
    end component;

    signal a, b: bit_vector(5 downto 0);
    signal a_in, b_in: bit_vector(5 downto 0); -- Fio que liga o MUX ao REG

    begin 

        regA: register6
        port map (clock, '0', h1, a_in, a);

        regB: register6
        port map (clock, '0', h2, b_in, b);

        regCMD: register6
        port map (clock, '0', x1, a, mdc);

        a_in <= a_en when (s1 = '0') else 
                bit_vector((unsigned(a) - unsigned(b)));

        b_in <= b_en when (s2 = '0') else
                bit_vector((unsigned(b) - unsigned(a)));

        -- Sinais de condicao para UC
        diferente <= '1' when (a /= b) else '0';
        maior <= '1' when (a > b) else '0';
end architecture;

entity MDC6 is
    port(
    clock, reset: in bit; -- Entrada de controle global
    iniciar: in bit; -- Entrada de controle
    a_en, b_en: in bit_vector(5 downto 0); -- Entrada de dados
    fim: out bit; -- Saida de controle
    mdc: out bit_vector(5 downto 0) -- Saida de dados
    );
end entity;

architecture arch_MDC6 of MDC6 is
    component UC is
        port(
            -- Sinais de controle global
            clock, reset: in bit;
            -- Sinais de status
            iniciar, diferente, maior: in bit;
            -- Sinais de controle 
            h1, h2, s1, s2, x1: out bit;
            -- Saida de controle
            fim: out bit
        );
    end component;

    component FD is
        port(
            -- Sinais de controle global
            clock: in bit;
            -- Sinais de controle da UC
            h1, h2, s1, s2, x1: in bit;
            -- Sinais de status
            diferente, maior: out bit; 
            -- Entrada de dados
            a_en, b_en: in bit_vector(5 downto 0);
            -- Entrada de controle 
            iniciar: in bit;
            -- Saida de dados
            mdc: out bit_vector(5 downto 0)
    
        );
    end component;

    signal h1, h2, s1, s2, x1, diferente, maior: bit; 
    signal clock_n: bit;

    begin
        clock_n <= not(clock);

        xUC: UC
        port map(clock, reset, iniciar, diferente, maior, h1, h2, s1, s2, x1, fim);

        xFD: FD
        port map(clock_n, h1, h2, s1, s2, x1, diferente, maior, a_en, b_en, iniciar, mdc);

end architecture;
