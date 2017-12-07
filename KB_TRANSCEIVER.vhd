LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY KB_TRANSCEIVER IS
	PORT(
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			HALT_REQ : IN STD_LOGIC;
			KBCLK : INOUT STD_LOGIC;
			KBDATA : INOUT STD_LOGIC;
			KEYSTATE : OUT STD_LOGIC;
			KEY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			EXTENDED : OUT STD_LOGIC
		);
END KB_TRANSCEIVER;

ARCHITECTURE main OF KB_TRANSCEIVER IS
SIGNAL KBCLKF : STD_LOGIC;
SIGNAL WR_EN : STD_LOGIC;
SIGNAL WR_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	PROCESS(KBCLKF, RST)
	VARIABLE REC_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);
	VARIABLE STATE : STD_LOGIC_VECTOR(3 DOWNTO 0);
	VARIABLE ITERATOR : INTEGER RANGE 0 TO 10;
	VARIABLE UNPRESSING : STD_LOGIC;
	BEGIN
		IF(RST = '1') THEN
			STATE := x"0";
			ITERATOR := 0;
			UNPRESSING := '0';
			KEY <= x"FF";
			KEYSTATE <= '0';
			EXTENDED <= '0';
		ELSIF(KBCLKF'EVENT AND KBCLKF = '0' AND WR_EN = '0') THEN
			CASE STATE IS
				WHEN x"0" =>
					KEYSTATE <= '1';
					STATE := x"1";
				WHEN x"1" =>
					REC_DATA(ITERATOR) := KBDATA;
					ITERATOR := ITERATOR + 1;
					IF(ITERATOR = 8) THEN
						STATE := x"2";
					END IF;
				WHEN x"2" =>
					IF(REC_DATA = x"E0") THEN
						EXTENDED <= '1';
					ELSIF(REC_DATA = x"F0") THEN
						UNPRESSING := '1';
					ELSIF(UNPRESSING = '1') THEN
						UNPRESSING := '0';
						KEYSTATE <= '0';
						EXTENDED <= '0';
						KEY <= x"FF";
					ELSE
						KEY <= REC_DATA;
					END IF;
					ITERATOR := 0;
					STATE := x"3";
				WHEN x"3" =>
					STATE := x"0";
				WHEN OTHERS =>
			END CASE;
		END IF;
	END PROCESS;

	PROCESS(CLK, HALT_REQ, RST)
	VARIABLE STATE : STD_LOGIC_VECTOR(3 DOWNTO 0);
	VARIABLE COUNT : INTEGER RANGE 0 TO 5000;
	BEGIN
		IF(RST = '1') THEN
			STATE := x"0";
			WR_EN <= '0';
		ELSIF(CLK'EVENT AND CLK = '1' AND HALT_REQ = '1') THEN
			CASE STATE IS
				WHEN x"0" =>
					IF(COUNT = 5000) THEN
						COUNT := 0;
						KBCLK <= '1';
						STATE := x"1";
					END IF;
					KBCLK <= '0';
					COUNT := COUNT + 1;
				WHEN x"1" =>
					WR_DATA <= x"EE";
					WR_EN <= '1';
					STATE := x"1";
				WHEN x"2" =>
					IF(COUNT = 200) THEN
						COUNT := 0;
						WR_EN <= '0';
						STATE := x"3";
					END IF;
					COUNT := COUNT + 1;
				WHEN OTHERS =>
			END CASE;
		END IF;
	END PROCESS;

	PROCESS(KBCLK, WR_EN, RST)
	VARIABLE STATE : STD_LOGIC_VECTOR(3 DOWNTO 0);
	VARIABLE ITERATOR : INTEGER RANGE 0 TO 12;
	BEGIN
		IF(RST = '1') THEN
			STATE := x"0";
			ITERATOR := 0;
		ELSIF(KBCLK'EVENT AND KBCLK = '0' AND WR_EN = '1') THEN
			CASE STATE IS
				WHEN x"0" =>
					STATE := x"1";
				WHEN x"1" =>
					KBDATA <= WR_DATA(ITERATOR);
					ITERATOR := ITERATOR + 1;
					IF(ITERATOR = 8) THEN
						STATE := x"2";
					END IF;
				WHEN x"2" =>
					KBDATA <= WR_DATA(0) XOR WR_DATA(1) XOR WR_DATA(2) XOR WR_DATA(3) XOR WR_DATA(4) XOR WR_DATA(5) XOR WR_DATA(6) XOR WR_DATA(7);
					ITERATOR := 0;
					STATE := x"3";
				WHEN x"3" =>
					STATE := x"3";
				WHEN OTHERS =>
			END CASE;
		ELSIF(KBCLK'EVENT AND KBCLK = '0' AND WR_EN = '0') THEN
			STATE := x"0";
		END IF;
	END PROCESS;

	PROCESS(CLK)
	VARIABLE CLK_FILTER : STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
		IF(CLK'EVENT AND CLK = '1') THEN
			CLK_FILTER(6 DOWNTO 0) := CLK_FILTER(7 DOWNTO 1);
			CLK_FILTER(7) := KBCLK;
			IF(CLK_FILTER = "11111111") THEN
				KBCLKF <= '1';
			ELSIF(CLK_FILTER = "00000000") THEN 
				KBCLKF <= '0';
			END IF;
		END IF;
	END PROCESS;
END main;