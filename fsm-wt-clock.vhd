LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY vending_machine IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        KEY      : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        SW       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        LEDR     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        HEX0     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX1     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END vending_machine;

ARCHITECTURE Comportamental OF vending_machine IS

    TYPE state_type IS (ST0, ST5, ST10, ST15, ST20, ST25, ST30, ST35, ST40, ST45);
    SIGNAL state        : state_type := ST0;
    SIGNAL prev_insert  : std_logic := '1';
    SIGNAL insert_pulse : std_logic := '0';

    CONSTANT dois_sec : integer := 200_000_000;
    SIGNAL conta2      : integer range 0 to dois_sec := 0;
    SIGNAL timer_pulse     : std_logic := '0';

BEGIN

    PROCESS (CLOCK_50)
        VARIABLE next_state : state_type;
    BEGIN
        IF rising_edge(CLOCK_50) THEN

            IF KEY(0) = '0' THEN
                state         <= ST0;
                LEDR          <= "000";
                HEX0          <= "1000000";
                HEX1          <= "1000000";
                conta2    <= 0;
                timer_pulse   <= '0';

            ELSE
                insert_pulse <= '0';
                IF prev_insert = '1' AND KEY(1) = '0' THEN
                    insert_pulse <= '1';
                END IF;
                prev_insert <= KEY(1);

                IF conta2 = dois_sec THEN
                    timer_pulse  <= '1';
                    conta2   <= 0;
                ELSE
                    conta2   <= conta2 + 1;
                    timer_pulse  <= '0';
                END IF;

                next_state := state;

                IF state <= ST20 AND insert_pulse = '1' THEN
                    CASE state IS
                        WHEN ST0 =>
                            CASE SW IS
                                WHEN "01" => next_state := ST5;
                                WHEN "10" => next_state := ST10;
                                WHEN "11" => next_state := ST25;
                                WHEN OTHERS => next_state := ST0;
                            END CASE;

                        WHEN ST5 =>
                            CASE SW IS
                                WHEN "01" => next_state := ST10;
                                WHEN "10" => next_state := ST15;
                                WHEN "11" => next_state := ST30;
                                WHEN OTHERS => next_state := ST5;
                            END CASE;

                        WHEN ST10 =>
                            CASE SW IS
                                WHEN "01" => next_state := ST15;
                                WHEN "10" => next_state := ST20;
                                WHEN "11" => next_state := ST35;
                                WHEN OTHERS => next_state := ST10;
                            END CASE;

                        WHEN ST15 =>
                            CASE SW IS
                                WHEN "01" => next_state := ST20;
                                WHEN "10" => next_state := ST25;
                                WHEN "11" => next_state := ST40;
                                WHEN OTHERS => next_state := ST15;
                            END CASE;

                        WHEN ST20 =>
                            CASE SW IS
                                WHEN "01" => next_state := ST25;
                                WHEN "10" => next_state := ST30;
                                WHEN "11" => next_state := ST45;
                                WHEN OTHERS => next_state := ST20;
                            END CASE;

                        WHEN OTHERS => NULL;
                    END CASE;

                ELSIF state >= ST25 AND timer_pulse = '1' THEN
                    CASE state IS
                        WHEN ST25 | ST30 | ST35 =>
                            next_state := ST0;

                        WHEN ST40 | ST45 =>
                            next_state := ST35;

                        WHEN OTHERS => NULL;
                    END CASE;
                END IF;

                state <= next_state;

                CASE next_state IS
                    WHEN ST0   => LEDR <= "000"; HEX1 <= "1000000"; HEX0 <= "1000000";
                    WHEN ST5   => LEDR <= "000"; HEX1 <= "1000000"; HEX0 <= "0010010";
                    WHEN ST10  => LEDR <= "000"; HEX1 <= "1111001"; HEX0 <= "1000000";
                    WHEN ST15  => LEDR <= "000"; HEX1 <= "1111001"; HEX0 <= "0010010";
                    WHEN ST20  => LEDR <= "000"; HEX1 <= "0100100"; HEX0 <= "1000000";
                    WHEN ST25  => LEDR <= "100"; HEX1 <= "0100100"; HEX0 <= "0010010";
                    WHEN ST30  => LEDR <= "101"; HEX1 <= "0110000"; HEX0 <= "1000000";
                    WHEN ST35  => LEDR <= "110"; HEX1 <= "0110000"; HEX0 <= "0010010";
                    WHEN ST40  => LEDR <= "001"; HEX1 <= "0011001"; HEX0 <= "1000000";
                    WHEN ST45  => LEDR <= "010"; HEX1 <= "0011001"; HEX0 <= "0010010";
                    WHEN OTHERS => LEDR <= "000"; HEX1 <= "1111111"; HEX0 <= "1111111";
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END Comportamental;
