
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopModuleJuego is
    Port (
        -- Entradas Físicas (Botones y Reloj)
        clk      : in  std_logic;          -- Pin 52
        reset    : in  std_logic;          -- Botón S1 (Pin 3 o 4)
        mov      : in  std_logic;          -- Botón para mover
        enter    : in  std_logic;          -- Botón Enter
        
        -- Salidas Gato (Matriz)
        rows     : out std_logic_vector(0 to 7);
        cols     : out std_logic_vector(0 to 7);
        
        -- Salidas CPU (Display y LEDs)
        seg      : out std_logic_vector(0 to 7);
        an       : out std_logic_vector(3 downto 0)
        
    );
end TopModuleJuego;

architecture Behavioral of TopModuleJuego is
signal pun1, pun2, puntaje: std_logic_vector(15 downto 0):=(others=>'0');
signal patrones: std_logic_vector(63 downto 0);
signal jug1,jug2: std_logic_vector(0 to 8);
    -- Declaración del GATO (Debe coincidir con tu archivo topModule.vhd)
    component top_module is
        Port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            mov      : in  std_logic;
            enter    : in  std_logic;
            rows     : out std_logic_vector(0 to 7);
            cols     : out std_logic_vector(0 to 7);
            ganador, empat, casilla, turno, movi, ini : out std_logic;
            sjugador, sjugador1 : out std_logic_vector(0 to 8);
            FilasPatron : in std_logic_vector(63 downto 0);
            j1,j2: out STD_LOGIC_VECTOR(0 to 8);
              gana: out std_logic_vector(1 downto 0);
            sumar2     : out std_logic_vector(1 downto 0);
            torneo   : out std_logic; -- NUEVA SALIDA
            estados  : out std_logic_vector(0 to 8)
        );
    end component;

    -- Declaración del CPU (Debe coincidir con tu archivo TopModule.vhd)
    component TopModule is
        port( 
            clk, reset, pause_run : in std_logic;
            Sel_program : in std_logic_vector(2 downto 0);
            PC_Btn      : in std_logic;
            PC_Btn_out  : out std_logic;
            seg         : out std_logic_vector(0 to 7);
            an          : out std_logic_vector(3 downto 0);
            ledsd       : out std_logic_vector(3 downto 0);
            
            asr         : out std_logic_vector(4 downto 0);
            puntaje1: out std_logic_vector(15 downto 0);
            puntaje2: out std_logic_vector(15 downto 0);
            FilasPatron : out std_logic_vector(63 downto 0);
            j1,j2: in STD_LOGIC_VECTOR(0 to 8);
             gana: in std_logic_vector(1 downto 0);
             ganador, empat, ini : in std_logic;
            sumar2     : in std_logic_vector(1 downto 0);
            torneo   : in std_logic; -- NUEVA SALIDA
            ZF, CF, SF, OvF : out std_logic
        );
    end component;

 component display is
        port (
            Datos     : in  std_logic_vector(15 downto 0);
            clk_27mhz : in  std_logic;
            seg       : out std_logic_vector(0 to 7);
            an        : out std_logic_vector(3 downto 0)
        );
    end component;



signal win,ini,emp,torn: std_logic;
signal ganador,sum2:std_logic_vector(1 downto 0);

begin

    -- 1. INSTANCIA DEL GATO (Conectado a los pines reales)
    Gato: top_module port map (
        clk      => clk,
        reset    => reset,
        mov      => mov,         
        enter    => enter, 
        rows     => rows, 
        cols     => cols,
        -- Salidas internas del gato (sin usar por ahora)
        ganador  => win,
        empat    => emp,
        casilla  => open,
        turno    => open,
        movi     => open,
        ini      => ini,
        sjugador => open,
        sjugador1=> open, 
        FilasPatron=>patrones,
        j1=>jug1,
        j2=>jug2,
        gana=>ganador,
        sumar2=>sum2,
        torneo=>torn,
        estados  => open
    );

    -- 2. INSTANCIA CPU (Conectado pero "en pausa")
    CPU : TopModule port map(
        clk         => clk,
        reset       => reset,
        
        -- Controles fijos para que no moleste
        pause_run   => '1',    -- '0' pone al CPU en PAUSA (según tu lógica)
        Sel_program => "000",  -- Programa 0 por defecto
        PC_Btn      => '1',    -- Botón sin presionar (pull-up)
        
        -- Salidas
        PC_Btn_out  => open,
        seg         => seg,    -- Conectado al display (mostrará ceros o nada)
        an          => an,     -- Conectado a ánodos
          -- Conectado a los LEDs de la placa
        ledsd       => open,  -- Conectado si tienes LEDs externos
        
        -- Salidas sin usar
        asr         => open,
        puntaje1   => pun1,
         puntaje2   => pun2,
        FilasPatron => patrones,
         j1=>jug1,
        j2=>jug2,
         gana=>ganador,
         ganador=>win,
        empat=>emp,
        ini=>ini,
         sumar2=>sum2,
         torneo=>torn,
        ZF          => open,
        CF          => open,
        SF          => open,
        OvF         => open
    );




end Behavioral;