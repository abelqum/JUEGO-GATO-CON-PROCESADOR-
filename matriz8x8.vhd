    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

    entity led_matrix_8x8 is
        Port (
            clk     : in  STD_LOGIC;      -- Reloj del sistema (ej. 50 MHz)
            reset   : in  STD_LOGIC;      -- Reset activo alto
            rows    : out STD_LOGIC_VECTOR(0 to 7);  -- Salidas para filas (ánodo)
            j1,j2: in STD_LOGIC_VECTOR(0 to 8);
             gan,emp,comienzo: in std_logic;
            jactual: in std_logic;
                 gana: in std_logic_vector(1 downto 0);  
            FilasPatron : in std_logic_vector(63 downto 0);
            cols    : out STD_LOGIC_VECTOR(0 to 7)   -- Salidas para columnas (cátodo)
        );
    end led_matrix_8x8;

    architecture Behavioral of led_matrix_8x8 is
        signal refresh_counter : std_logic:='0';
        signal col_selector    : integer:= 0;
        signal row_pattern     : STD_LOGIC_VECTOR(7 downto 0);
        signal col_pattern     : STD_LOGIC_VECTOR(0 to 7);
       
        -- Constante para el divisor de frecuencia (ajustar según necesidad)
        signal REFRESH_DIVIDER : integer := 0; -- Para ~1 kHz de tasa de refresco
        signal pat0,pat1,pat2,pat3,pat4,pat5,pat6,pat7: std_logic_vector(7 downto 0);
        
    begin
    pat0 <= FilasPatron(63 downto 56);
    pat1 <= FilasPatron(55 downto 48);
    pat2 <= FilasPatron(47 downto 40);
    pat3 <= FilasPatron(39 downto 32);
    pat4 <= FilasPatron(31 downto 24);
    pat5 <= FilasPatron(23 downto 16);
    pat6 <= FilasPatron(15 downto 8);
    pat7 <= FilasPatron(7 downto 0);

        -- Proceso para el contador de refresco y selección de fila
       process(clk)
        begin
            if rising_edge(clk) then
                if REFRESH_DIVIDER= 13500 then
                    REFRESH_DIVIDER <= 0;
                   refresh_counter <= not refresh_counter;
                else
                    REFRESH_DIVIDER <= REFRESH_DIVIDER + 1;
                end if;
            end if;
        end process;
        
         -- Multiplexor de displays
        process(refresh_counter)
        begin
            if rising_edge(refresh_counter) then
                col_selector <= (col_selector + 1) mod 8;
            end if;
        end process;

    -- Selección del dígito actual
        process(col_selector)
        begin
        
            case col_selector is
                when 0 =>
                     col_pattern <= "10000000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                     row_pattern<=pat0;
                when 1 =>
                     col_pattern <= "01000000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                   row_pattern<=pat1;
                when 2 =>
                     col_pattern <= "00100000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                     row_pattern<=pat2;
                when 3 =>
                     col_pattern <= "00010000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                     row_pattern<=pat3;
                when 4 =>
                     col_pattern <= "00001000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                      row_pattern<=pat4;
                when 5 =>
                     col_pattern <= "00000100"; -- Columna 2 encendida (bit 1 en 0)  0-7
                     row_pattern<=pat5;
                when 6 =>
                     col_pattern <= "00000010"; -- Columna 2 encendida (bit 1 en 0)  0-7
                          row_pattern<=pat6;
                when 7 =>
                     col_pattern <= "00000001"; -- Columna 2 encendida (bit 1 en 0)  0-7
                     row_pattern<=pat7;
                when others =>
                   null;
            end case;
    end process;
        
       
        -- Asignación de salidas
        rows <= row_pattern;
        cols <= col_pattern;
        
    end Behavioral;