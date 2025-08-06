LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY vending_machine IS
    PORT (
    CLK : IN STD_LOGIC;
    SW       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    KEY      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    HEX0, HEX1, HEX2, HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    )
END vending_machine;

ARCHITECTURE fsm OF vending_machine IS
    TYPE state IS (st0, st5, st10, st15, st20, st25,
    st30, st35, st40, st45);
    SIGNAL present_state, next_state: STATE;	 
	 SIGNAL nickel_in, dime_in, quarter_in : STD_LOGIC := '0';
    SIGNAL candy_out, nickel_out, dime_out : STD_LOGIC := '0';
	 
BEGIN

 ---- Lower section of the FSM (Sec. 8.2): ---------
 
	PROCESS(SW, KEY, nickel_in, dime_in, quarter_in)
    BEGIN
        -- Detect key press (active low on DE10-Lite)
        if (KEY(0) = '0') then
            case SW is
                when "0001" => nickel_in  <= '1';
                when "0010" => dime_in    <= '1';
                when "0100" => quarter_in <= '1';
            end case;
        end if;
    END PROCESS;
 
 
    PROCESS (SW, KEY, nickel_in, dime_in, quarter_in)
        BEGIN
		  if (KEY(0) = '0') then
            case SW is
                when "0001" => nickel_in  <= '1';
                when "0010" => dime_in    <= '1';
                when "0100" => quarter_in <= '1';
                when others => null;
            end case;
		  
        IF (KEY='1') THEN
            present_state <= st0;
        ELSIF (CLK'EVENT AND CLK='1') THEN
            present_state <= next_state;
        END IF;
    END PROCESS;

 ---- Upper section of the FSM (Sec. 8.2): ---------
    PROCESS (present_state, nickel_in, dime_in, quarter_in)
    BEGIN
        CASE present_state IS
            WHEN st0 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF (nickel_in) THEN next_state <= st5;
                ELSIF (dime_in) THEN next_state <= st10;
                ELSIF (quarter_in) THEN next_state <= st25;
                ELSE next_state <= st0;
                END IF;

            WHEN st5 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF (nickel_in) THEN next_state <= st10;
                ELSIF (dime_in) THEN next_state <= st15;
                ELSIF (quarter_in) THEN next_state <= st30;
                ELSE next_state <= st5;
                END IF;

            WHEN st10 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF (nickel_in) THEN next_state <= st15;
                ELSIF (dime_in) THEN next_state <= st20;
                ELSIF (quarter_in) THEN next_state <= st35;
                ELSE next_state <= st10;
                END IF;

            WHEN st15 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF (nickel_in) THEN next_state <= st20;
                ELSIF (dime_in) THEN next_state <= st25;
                ELSIF (quarter_in) THEN next_state <= st40;
                ELSE next_state <= st15;
                END IF;

            WHEN st20 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '0';
                IF (nickel_in) THEN next_state <= st25;
                ELSIF (dime_in) THEN next_state <= st30;
                ELSIF (quarter_in) THEN next_state <= st45;
                ELSE next_state <= st20;
                END IF;

            WHEN st25 =>
                candy_out <= '1';
                nickel_out <= '0';
                dime_out <= '0';
                next_state <= st0;

            WHEN st30 =>
                candy_out <= '1';
                nickel_out <= '1';
                dime_out <= '0';
                next_state <= st0;

            WHEN st35 =>
                candy_out <= '1';
                nickel_out <= '0';
                dime_out <= '1';
                next_state <= st0;

            WHEN st40 =>
                candy_out <= '0';
                nickel_out <= '1';
                dime_out <= '0';
                next_state <= st35;

            WHEN st45 =>
                candy_out <= '0';
                nickel_out <= '0';
                dime_out <= '1';
                next_state <= st35;
END CASE;

END PROCESS;

END fsm;
