LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;

LIBRARY std;
USE std.textio.ALL;

ENTITY data_maker IS
  GENERIC (
    NBIT : INTEGER := 9);
  PORT (
    CLK : IN STD_LOGIC;
    RST_n : IN STD_LOGIC;
    VOUT : OUT STD_LOGIC;
    DOUT : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    B0 : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    B1 : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    A1 : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    END_SIM : OUT STD_LOGIC);
END data_maker;

ARCHITECTURE beh OF data_maker IS

  CONSTANT tco : TIME := 2 ns;
  CONSTANT N_CYC_END_SIM : INTEGER := 11;
  CONSTANT LFSR_INIT : INTEGER := 1365;

  SIGNAL sEndSim : STD_LOGIC;
  SIGNAL END_SIM_i : STD_LOGIC_VECTOR(0 TO N_CYC_END_SIM - 1);

  SIGNAL lfsr : STD_LOGIC_VECTOR(11 DOWNTO 0);
  SIGNAL valid : STD_LOGIC;

BEGIN -- beh

  B0 <= conv_std_logic_vector(107, NBIT);
  B1 <= conv_std_logic_vector(107, NBIT);
  A1 <= conv_std_logic_vector(-41, NBIT);

  PROCESS (CLK, RST_n)
    FILE fp_in : text OPEN READ_MODE IS "./samples.txt";
    VARIABLE line_in : line;
    VARIABLE x : INTEGER;
  BEGIN -- process
    IF RST_n = '0' THEN -- asynchronous reset (active low)
      DOUT <= (OTHERS => '0') AFTER tco;
      VOUT <= '0' AFTER tco;
      sEndSim <= '0' AFTER tco;
    ELSIF CLK'event AND CLK = '1' THEN -- rising clock edge
      IF NOT endfile(fp_in) THEN
        IF (valid = '1') THEN
          readline(fp_in, line_in);
          read(line_in, x);
          DOUT <= conv_std_logic_vector(x, 9) AFTER tco;
          VOUT <= '1' AFTER tco;
          sEndSim <= '0' AFTER tco;
        ELSE
          VOUT <= '0' AFTER tco;
          sEndSim <= '0' AFTER tco;
        END IF;
      ELSE
        VOUT <= '0' AFTER tco;
        sEndSim <= '1' AFTER tco;
      END IF;
    END IF;
  END PROCESS;

  PROCESS (CLK, RST_n) IS
  BEGIN -- process
    IF RST_n = '0' THEN -- asynchronous reset (active low)
      valid <= '0' AFTER tco;
      lfsr <= conv_std_logic_vector(LFSR_INIT, 12) AFTER tco;
    ELSIF CLK'event AND CLK = '1' THEN -- rising clock edge
      lfsr <= (lfsr(0) XOR lfsr(1)) & sxt(lfsr(11 DOWNTO 2), 11) AFTER tco;
      valid <= lfsr(0) AFTER tco;
      --valid <= '1';
    END IF;
  END PROCESS;

  PROCESS (CLK, RST_n)
  BEGIN -- process
    IF RST_n = '0' THEN -- asynchronous reset (active low)
      END_SIM_i <= (OTHERS => '0') AFTER tco;
    ELSIF CLK'event AND CLK = '1' THEN -- rising clock edge
      END_SIM_i(0) <= sEndSim AFTER tco;
      END_SIM_i(1 TO 10) <= END_SIM_i(0 TO 9) AFTER tco;
    END IF;
  END PROCESS;

  END_SIM <= END_SIM_i(10);

END beh;
