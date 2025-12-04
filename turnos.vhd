library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turnos is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        enter    : in  std_logic;
        mov      : in  std_logic;
        win      : in  std_logic;
        empat    : in  std_logic;
        jActual  : out std_logic;
        sum2     : out std_logic_vector(1 downto 0);
        torneo   : out std_logic; 
        comienzo : out std_logic
    );
end entity;

architecture Behavioral of turnos is
    type t_estado is (INICIO, S_TORNEO, PRE_GAME, PLAYER1, PLAYER2, WINNER, EMPATE, FIN_TORNEO);
    signal presente, siguiente : t_estado := INICIO;
    
    signal sum_reg : std_logic_vector(1 downto 0) := "00";
    signal sum_timer : integer range 0 to 2000 := 0; 
    
    signal wins1 : integer range 0 to 3 := 0;
    signal wins2 : integer range 0 to 3 := 0;
    signal games : integer range 0 to 3 := 0;
    signal flag_torneo : std_logic := '0';

begin
    process(clk, reset)
    begin
        if reset = '0' then
            presente <= INICIO;
            sum_timer <= 0;
            sum_reg <= "00";
            wins1 <= 0; wins2 <= 0; games <= 0;
            flag_torneo <= '0';
        elsif rising_edge(clk) then
            presente <= siguiente;
            
            if presente = S_TORNEO and enter = '0' then
                wins1 <= 0; wins2 <= 0; games <= 0;
                flag_torneo <= '1';
            elsif presente = INICIO and enter = '0' then
                flag_torneo <= '0';
            end if;

            if (presente = PLAYER1 or presente = PLAYER2) then
                if siguiente = WINNER then
                    games <= games + 1;
                    if presente = PLAYER1 then wins1 <= wins1 + 1; else wins2 <= wins2 + 1; end if;
                elsif siguiente = EMPATE then
                    games <= games + 1;
                end if;
            end if;

            if sum_timer > 0 then sum_timer <= sum_timer - 1; else sum_reg <= "00"; end if;

            if presente = FIN_TORNEO then
                sum_reg <= "11"; sum_timer <= 100;
            elsif enter = '0' then 
                if presente = PLAYER1 then sum_reg <= "01"; sum_timer <= 2000;
                elsif presente = PLAYER2 then sum_reg <= "10"; sum_timer <= 2000; end if;
            end if;
            if presente = INICIO then sum_reg <= "00"; end if;
        end if;
    end process;

    sum2 <= sum_reg;
    torneo <= '1' when (presente = S_TORNEO or flag_torneo = '1') else '0';

    process(presente, enter, mov, win, empat, wins1, wins2, games, flag_torneo)
    begin
        siguiente <= presente;
        comienzo <= '0';
        jActual <= '0'; 

        case presente is
            when INICIO =>
                comienzo <= '1';
                if mov = '0' then siguiente <= S_TORNEO;
                elsif enter = '0' then siguiente <= PLAYER1; end if;
            
            when S_TORNEO =>
                comienzo <= '1';
                if mov = '0' then siguiente <= INICIO;
                elsif enter = '0' then siguiente <= PLAYER1; end if;

            when PRE_GAME =>
                comienzo <= '1'; siguiente <= PLAYER1; 

            when PLAYER1 =>
                jActual <= '0';
                if win = '1' then siguiente <= WINNER;
                elsif empat = '1' then siguiente <= EMPATE;
                elsif enter = '0' then siguiente <= PLAYER2; end if;

            when PLAYER2 =>
                jActual <= '1';
                if win = '1' then siguiente <= WINNER;
                elsif empat = '1' then siguiente <= EMPATE;
                elsif enter = '0' then siguiente <= PLAYER1; end if;

            when WINNER =>
                if enter = '0' then 
                    if flag_torneo = '1' then
                        if wins1 >= 2 or wins2 >= 2 or games >= 3 then siguiente <= FIN_TORNEO;
                        else siguiente <= PRE_GAME; end if;
                    else siguiente <= INICIO; end if;
                end if;

            when EMPATE =>
                if enter = '0' then 
                    if flag_torneo = '1' then
                        if games >= 3 then siguiente <= FIN_TORNEO;
                        else siguiente <= PRE_GAME; end if;
                    else siguiente <= INICIO; end if;
                end if;
            
            when FIN_TORNEO => null; 
            when others => siguiente <= INICIO;
        end case;
    end process;
end Behavioral;