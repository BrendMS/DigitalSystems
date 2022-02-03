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