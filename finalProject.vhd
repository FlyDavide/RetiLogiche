----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.03.2023 10:32:46
-- Design Name: Davide Vola
-- Module Name: 10774133 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Progetto reti logiche 2022/2023
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
       i_rst : in STD_LOGIC;
       i_start : in STD_LOGIC;
       i_w : in STD_LOGIC;
       o_z0 : out STD_LOGIC_VECTOR (7 downto 0);
       o_z1 : out STD_LOGIC_VECTOR (7 downto 0);
       o_z2 : out STD_LOGIC_VECTOR (7 downto 0);
       o_z3 : out STD_LOGIC_VECTOR (7 downto 0);
       o_done : out STD_LOGIC;
       o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0);
       i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
       o_mem_we : out STD_LOGIC;
       o_mem_en : out STD_LOGIC);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    ---------------------------------------------------------
    -- Segnali Macchina a Stati (modulo 1) :
    type STATES is (S0, S1, S2, S3);
    signal CS, NS : STATES; -- CS: Stato Corrente; NS: Stato Prossimo.
    signal Ar1 : STD_LOGIC; -- Attiva il registro 1 per permetterli di salvare l'indirizzo di uscita del dato
    signal ON2 : STD_LOGIC; --Attiva il modulo 2 (lo accende)
    ---------------------------------------------------------
    -- Segnali Registro 1 : (registro che salva l'uscita che devrà essere attivata)
    signal R1: std_logic_vector(1 downto 0);
    ---------------------------------------------------------
    -- Segnali Modulo 2:
    signal Ar2 : STD_LOGIC; -- arriva il registro per salvare l'indirizzo del Dato
    signal ON3 : std_logic; -- Attiva il modulo 3;
    ---------------------------------------------------------
    signal R2 : std_logic_vector(15 downto 0);
    ---------------------------------------------------------
    -- Segnali Modulo 3:
    signal Ad : STD_LOGIC_VECTOR(3 downto 0);
    ---------------------------------------------------------
    -- Segnali Registro Dati:
    signal D0 : std_logic_vector (7 downto 0);
    signal D1 : std_logic_vector (7 downto 0);
    signal D2 : std_logic_vector (7 downto 0);
    signal D3 : std_logic_vector (7 downto 0);
    --------------------------------------------------------- 
    -- Segnali Modulo 4:
    signal ActivZ : std_logic;
    ---------------------------------------------------------
    -- Segnali di Ritardo Done:
    signal Stop : std_logic; --Serve per far uscire il Risultato sia dei registri Dati e attiva il o_done a 1. Deve anche resettare il Modulo 1, portado la macchina a stati all'inizio.
    signal Rit : std_logic_vector (3 downto 0); --Ritardo per far uscire Done in un solo ciclo clk
    --------------------------------------------------------
    --------------------------------------------------------
    begin
    -- Mod 1:
    state_reg : process(i_clk, i_rst, ActivZ)
    begin
        if i_rst = '1' then
            CS <= S0;
        elsif i_clk'event and i_clk = '1' then
            if ActivZ = '1' then
                CS <= S0;
            else
                CS <= NS;
            end if;
        end if;
    end process;
    ---------------------
    attivStat : process(CS, i_start, i_rst)
    begin
        case CS is
            when S0 =>
                if i_start = '1' and i_rst = '0' then
                    NS <= S1;
                else 
                    NS <= S0;
                end if;
            when S1 =>
                NS <= S2;
            when S2 =>
                NS <= S3;
            when S3 =>
                NS <= S3;
        end case;  
    end process;
    ---------------------
    UscitaStati: process(NS)
    begin
        case NS is
            when S0 =>
                Ar1 <= '0';
                ON2 <= '0';
            when S1 | S2 =>
                Ar1 <= '1';
                ON2 <= '0';
            when S3 =>
                Ar1 <= '0';
                ON2 <= '1';
        end case;
    end process;
    ----------------------------------------------
    -- Registro 1:
    Registro1: process(i_clk, i_rst, Ar1)
    begin
        if i_rst = '1' then
            R1 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if Ar1 = '1' then
                R1(0) <= i_w;
                R1(1) <= R1(0);
            else
                R1(0) <= R1(0);
                R1(1) <= R1(1);
            end if;
        end if;
    end process;
    ----------------------------------------------
    -- Registro 2:
    Registro2 : process (i_clk, i_rst, Ar2, ON2)
    begin
        if i_rst = '1' or ON2 = '0' then
            R2 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if Ar2 = '1' then
                R2(0) <= i_w;
                R2(1) <= R2(0);
                R2(2) <= R2(1);
                R2(3) <= R2(2);
                R2(4) <= R2(3);
                R2(5) <= R2(4);
                R2(6) <= R2(5);
                R2(7) <= R2(6);
                R2(8) <= R2(7);
                R2(9) <= R2(8);
                R2(10) <= R2(9);
                R2(11) <= R2(10);
                R2(12) <= R2(11);
                R2(13) <= R2(12);
                R2(14) <= R2(13);
                R2(15) <= R2(14);
            else
                R2 <= R2;
            end if;
        end if;      
    end process;
    o_mem_addr <= R2;
    ---------------------------------------------- 
    --Attivare Registro Dati che devono salvare il dato che arriva dalla memoria
    -- Mod3:
    AttivatoreRegDati: process(ON3, R1)
    begin
        if ON3 = '1' then
            case R1 is
                when "00" =>
                    Ad <= "0001";
                when "01" =>
                    Ad <= "0010";
                when "10" =>
                    Ad <= "0100";
                when "11" =>
                    Ad <= "1000";
                when others =>
                    Ad <= "0000";
            end case;
        else
            Ad <= "0000";
        end if;
    end process;
    ----------------------------------------------
    --Registro Dato 0:
    RegistroDato0: process (i_clk, i_rst, Ad(0))          
    begin
        if i_rst = '1' then
            D0 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if Ad(0) = '1' then
                D0 <= i_mem_data;
            else
                D0 <= D0;
            end if;
        end if;
    end process;
    ----------------------------------------------
    --Registro Dato 1:
    RegistroDato1: process (i_clk, i_rst, Ad(1))          
    begin
        if i_rst = '1' then
            D1 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if Ad(1) = '1' then
                D1 <= i_mem_data;
            else
                D1 <= D1;
            end if;
        end if;
    end process;
    ----------------------------------------------
    --Registro Dato 2:
    RegistroDato2: process (i_clk, i_rst, Ad(2))          
    begin
        if i_rst = '1' then
            D2 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if Ad(2) = '1' then
                D2 <= i_mem_data;
            else
                D2 <= D2;
            end if;
        end if;
    end process;
    ----------------------------------------------
    --Registro Dato 3:
    RegistroDato3: process (i_clk, i_rst, Ad(3))          
    begin
        if i_rst = '1' then
            D3 <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if Ad(3) = '1' then
                D3 <= i_mem_data;
            else
                D3 <= D3;
            end if;
        end if;
    end process;
    ----------------------------------------------    
    -- verifica che uno degli Ad (attivatori del registro) sia attivo in modo da poter additavere il o_done, ma  per un solo ciclo clk
    -- Ritardo di Done:
    Ritardo_Done : process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            Rit <= "0000";
        elsif i_clk'event and i_clk = '1' then
            Rit(3) <= ON3;
            Rit(2 downto 0) <= Rit(3 downto 1);
        end if;
    end process;
    Stop <= Rit(1) and (not Rit(0)); --Attiva il modello 4, facendo uscire il risultato dei registri dati
    ActivZ <= Stop when Stop = '1' else '0';
    o_done <= ActivZ;
    ----------------------------------------------
    --Attivatore Salvataggio Registro2 : per salvare l'indirizzo del dato( atttiva il salvataggio dei bit di i_w nel registro)
    --- Mod: 2
    Ar2 <= ON2 and i_start;
    o_mem_en <= (not i_start) and ON2;
    o_mem_we <= i_start;
    ON3 <= (not i_start) and ON2;
    ---------------------------------------------- 
    -- Gestisce l'uscita dei Dati, in caso in cui Yd (ciò o_done) è 1 deve far uscire i risultati salvati nel registro, in caso sia opposto fa uscire solo 0
    -- Mod 4:
    AttivUscitaZ: process(ActivZ, D3, D2, D1, D0)
    begin
        if ActivZ = '1' then    
            o_z3 <= D3;
            o_z2 <= D2;
            o_z1 <= D1;
            o_z0 <= D0;
        else
            o_z3 <= (others => '0');
            o_z2 <= (others => '0');
            o_z1 <= (others => '0');
            o_z0 <= (others => '0');
        end if;
    end process;
    ----------------------------------------------
end Behavioral;
