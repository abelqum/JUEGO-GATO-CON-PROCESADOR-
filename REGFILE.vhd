library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity RF is
port(
    clk         : in  std_logic; 
    A           : in  std_logic_vector(7 downto 0);
    B           : in  std_logic_vector(7 downto 0);
    Reset       : in  std_logic;
    Dest        : in  std_logic_vector(7 downto 0);
    Data_in     : in  std_logic_vector(15 downto 0);
    EnRF        : in  std_logic; 
    A_out       : out std_logic_vector(15 downto 0);
    asr         : out std_logic_vector( 4 downto 0 );
    B_out       : out std_logic_vector(15 downto 0);
    Puntaje1    : out std_logic_vector(15 downto 0);
    Puntaje2    : out std_logic_vector(15 downto 0);
    FilasPatron : out std_logic_vector(63 downto 0)
);
end RF;

architecture Behavioral of RF is
    signal asr16: std_logic_vector(15 downto 0);
    
    -- Array de 32 registros (0 a 31)
    type RegFile is array (0 to 31) of std_logic_vector(15 downto 0);
    
    signal TablaReg : RegFile := (
        0 => (others => '0'),  -- R0
        1 => (others => '0'),  -- R1
        2 => (others => '0'),  -- R2
        3 => (others => '0'),  -- R3
        4 => (others => '0'),  -- R4
        5 => (others => '0'),  -- R5
        6 => (others => '0'),  -- R6 (Puntaje 1)
        7 => (others => '0'),  -- R7 (Puntaje 2)
        -- Registros de Video (R8 - R15) inicializados con Gato
        8 => "00000000"&"00011110", -- R8 col 0
        9 => "00000000"&"10101001", -- R9 col 1
        10 => "00000000"&"10010000", -- R10 col 2
        11 => "00000000"&"10101000", -- R11 col 3
        12 => "00000000"&"00011000", -- R12 col 4
        13 => "00000000"&"11111100", -- R13 col 5
        14 => "00000000"&"11111110", -- R14 col 6
        15 => "00000000"&"11000001", -- R15 col 7
        others => (others => '0')   -- R16 a R31 en 0
    );

    -- Señales internas ahora van de 0 a 31 (5 bits)
    signal addr_a, addr_b, addr_dest : integer range 0 to 31;

begin
    -- Tomamos 5 bits (4 downto 0) para direccionamiento 32 regs
    addr_a    <= to_integer(unsigned(A(4 downto 0)));
    addr_b    <= to_integer(unsigned(B(4 downto 0)));
    addr_dest <= to_integer(unsigned(Dest(4 downto 0)));

    process(clk, Reset)
    begin
        if Reset = '0' then
            -- Reset explícito de R0-R7
            TablaReg(0) <= (others => '0');
            TablaReg(1) <= (others => '0');
            TablaReg(2) <= (others => '0');
            TablaReg(3) <= (others => '0');
            TablaReg(4) <= (others => '0');
            TablaReg(5) <= (others => '0');
            TablaReg(6) <= (others => '0');
            TablaReg(7) <= (others => '0');
            
            -- Reset de Video a Imagen Gato (R8-R15)
            TablaReg(8) <= "00000000"&"00011110";
            TablaReg(9) <= "00000000"&"10101001";
            TablaReg(10) <= "00000000"&"10010000";
            TablaReg(11) <= "00000000"&"10101000";
            TablaReg(12) <= "00000000"&"00011000";
            TablaReg(13) <= "00000000"&"11111100";
            TablaReg(14) <= "00000000"&"11111110";
            TablaReg(15) <= "00000000"&"11000001";
            
            -- Limpiamos el resto (R16-R31) con un loop para ahorrar líneas
            for i in 16 to 31 loop
                TablaReg(i) <= (others => '0');
            end loop;
            
        elsif rising_edge(clk) then
            if EnRF = '1' then
                TablaReg(addr_dest) <= Data_in;
            end if;
        end if;
    end process;

    A_out <= TablaReg(addr_a);
    B_out <= TablaReg(addr_b);
    
    -- Conexiones directas a Hardware
    Puntaje1 <= TablaReg(6);
    Puntaje2 <= TablaReg(7);
    
    -- Concatenación para la matriz (R8..R15)
    FilasPatron <= TablaReg(8)(7 downto 0) & TablaReg(9)(7 downto 0) & 
                   TablaReg(10)(7 downto 0) & TablaReg(11)(7 downto 0) & 
                   TablaReg(12)(7 downto 0) & TablaReg(13)(7 downto 0) & 
                   TablaReg(14)(7 downto 0) & TablaReg(15)(7 downto 0);

end Behavioral;