LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY myiir IS
	PORT (
		CLK, VIN, RST_n : IN STD_LOGIC;
		A12, B0, B1A1, B1mB0A1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		DIN : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		VOUT : OUT STD_LOGIC;
		DOUT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END myiir;

ARCHITECTURE rtl OF myiir IS

	COMPONENT REG IS
		GENERIC (N : INTEGER := 10);
		PORT (
			DIN : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			CLK, RST_n, EN : IN STD_LOGIC;
			DOUT : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL Out_MA12, Out_MB0, Out_MB1A1, Out_MB1mB0A1 : signed(18 DOWNTO 0);
	SIGNAL Out_A1 : signed(9 DOWNTO 0);
	SIGNAL Out_A2, Out_A3 : signed(5 DOWNTO 0);
	SIGNAL Out_REG_A12, Out_REG_B0, Out_REG_B1A1, Out_REG_B1mB0A1 : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL Out_REG_IN : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL Out_REG1 : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL Out_REG2, Out_REG3, Out_REG4, Out_REG5, Out_REG6_1, Out_REG6_2 : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL Valid : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

	Out_A1 <= ((Out_REG_IN(8) & signed(Out_REG_IN(8 DOWNTO 3))) + (Out_REG2(5) & signed(Out_REG2))) & signed(Out_REG_IN(2 DOWNTO 0)); --Input adder

	Out_MA12 <= signed(Out_REG1) * signed(Out_REG_A12);            --Multiplication by A1^2

	Out_MB1A1 <= signed(Out_REG1) * signed(Out_REG_B1A1);          --Multiplication by B1*A1

	Out_MB1mB0A1 <= signed(Out_REG1) * signed(Out_REG_B1mB0A1);    --Multiplication by B1-(B0*A1)

	Out_MB0 <= signed(Out_REG1) * signed(Out_REG_B0);              --Multiplication by B0

	Out_A2 <= signed(Out_REG4) - signed(Out_REG6_2);       --Subtractor

	Out_A3 <= signed(Out_REG5) + signed(Out_REG3);         --Output adder

	REG1 : REG GENERIC MAP(N => 10)
	PORT MAP(DIN => STD_LOGIC_VECTOR(Out_A1), CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG1);

	REG2 : REG GENERIC MAP(N => 6)
	PORT MAP(DIN => STD_LOGIC_VECTOR(Out_MA12(16 DOWNTO 11)), CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG2);

	REG6_1 : REG GENERIC MAP(N => 6)
	PORT MAP(DIN => STD_LOGIC_VECTOR(Out_MB1A1(16 DOWNTO 11)), CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG6_1);

	REG6_2 : REG GENERIC MAP(N => 6)
	PORT MAP(DIN => Out_REG6_1, CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG6_2);

	REG4 : REG GENERIC MAP(N => 6)
	PORT MAP(DIN => STD_LOGIC_VECTOR(Out_MB1mB0A1(16 DOWNTO 11)), CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG4);

	REG3 : REG GENERIC MAP(N => 6)
	PORT MAP(DIN => STD_LOGIC_VECTOR(Out_MB0(16 DOWNTO 11)), CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG3);

	REG5 : REG GENERIC MAP(N => 6)
	PORT MAP(DIN => STD_LOGIC_VECTOR(Out_A2), CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG5);

	REG_IN : REG GENERIC MAP(N => 9)   --Input register
	PORT MAP(DIN => DIN, CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG_IN);

	REG_OUT : REG GENERIC MAP(N => 6)  --Output register
	PORT MAP(DIN => STD_LOGIC_VECTOR(Out_A3), CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => DOUT(8 DOWNTO 3));

	DOUT(2 DOWNTO 0) <= "000"; --Adding of the LSBs to return to correct number of bits

	REG_A12 : REG GENERIC MAP(N => 9)      --Register for A1^2 coefficient
	PORT MAP(DIN => A12, CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG_A12);

	REG_B0 : REG GENERIC MAP(N => 9)       --Register for B0 coefficient
	PORT MAP(DIN => B0, CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG_B0);

	REG_B1A1 : REG GENERIC MAP(N => 9)     --Register for B1*A1 coefficient
	PORT MAP(DIN => B1A1, CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG_B1A1);

	REG_B1mB0A1 : REG GENERIC MAP(N => 9)  --Register for B1-(B0*A1) coefficient
	PORT MAP(DIN => B1mB0A1, CLK => CLK, RST_n => RST_n, EN => VIN, DOUT => Out_REG_B1mB0A1);

	Valid_process : PROCESS (CLK, RST_n)   --Shift register for valid signal (4 clock cycles delay)
	BEGIN
		IF (RST_n = '0') THEN

			Valid <= (OTHERS => '0');

			ELSIF (VIN = '1' AND CLK'EVENT AND CLK = '1') THEN

			Valid <= Valid(2 DOWNTO 0) & '1';

		END IF;
	END PROCESS;

	VOUT <= Valid(3) AND VIN;  --VOUT calculation

END ARCHITECTURE;
