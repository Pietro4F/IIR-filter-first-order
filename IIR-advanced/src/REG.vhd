LIBRARY ieee;
USE ieee.std_logic_1164.ALL;


ENTITY REG IS
	GENERIC (N : INTEGER := 8); --Number of bits
	PORT (
		DIN : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		CLK, RST_n, EN : IN STD_LOGIC;
		DOUT : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
	);
END REG;

ARCHITECTURE Behavior OF REG IS

BEGIN

	Register_process : PROCESS (CLK, RST_n)

	BEGIN

		IF (RST_n = '0') THEN
			DOUT <= (OTHERS => '0'); --Asynchronous reset

		ELSIF (EN = '1' AND CLK'EVENT AND CLK = '1') THEN
			DOUT <= DIN; --Sampling of the input

		END IF;

	END PROCESS;

END Behavior;
