LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;

LIBRARY std;
USE std.textio.ALL;

ENTITY data_sink IS
  GENERIC (
    NBIT : INTEGER := 9);
  PORT (
    CLK : IN STD_LOGIC;
    RST_n : IN STD_LOGIC;
    VIN : IN STD_LOGIC;
    DIN : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0));
END data_sink;

ARCHITECTURE beh OF data_sink IS

BEGIN -- beh

  PROCESS (CLK, RST_n)
    FILE res_fp : text OPEN WRITE_MODE IS "./results_hdl.txt";
    VARIABLE line_out : line;
    FILE fp_in : text OPEN READ_MODE IS "./results_c.txt";
    VARIABLE line_in : line;
    VARIABLE x : INTEGER;
    VARIABLE cnt : INTEGER := 0;
  BEGIN -- process
    IF RST_n = '0' THEN -- asynchronous reset (active low)
      cnt := 0;
    ELSIF CLK'event AND CLK = '1' THEN -- rising clock edge
      IF (VIN = '1') THEN
        write(line_out, conv_integer(signed(DIN)));
        writeline(res_fp, line_out);

        IF NOT endfile(fp_in) THEN
          readline(fp_in, line_in);
          read(line_in, x);
          ASSERT conv_integer(signed(DIN)) = x REPORT "Results are different: index=" & INTEGER'image(cnt) & " c=" & INTEGER'image(x) & " HDL=" & INTEGER'image(conv_integer(signed(DIN))) SEVERITY error;
        ELSE
          ASSERT VIN = '0' REPORT "Reached EOF in results_c.txt" SEVERITY error;
        END IF;
        cnt := cnt + 1;
      END IF;
    END IF;
  END PROCESS;

END beh;