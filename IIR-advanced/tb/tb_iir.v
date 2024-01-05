//`timescale 0.01ns

module tb_iir ();

   wire CLK_i;
   wire RST_n_i;
   wire [8:0] DIN_i;
   wire VIN_i;
   wire [8:0] A12_i;
   wire [8:0] B0_i;
   wire [8:0] B1A1_i;
   wire [8:0] B1mB0A1_i;
   wire [8:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .A12(A12_i),
		 .B0(B0_i),
		 .B1A1(B1A1_i),
		 .B1mB0A1(B1mB0A1_i),
		 .END_SIM(END_SIM_i));

   myiir UUT(.CLK(CLK_i),
	    .RST_n(RST_n_i),
	    .DIN(DIN_i),
        .VIN(VIN_i),
	    .A12(A12_i),
		.B0(B0_i),
		.B1A1(B1A1_i),
		.B1mB0A1(B1mB0A1_i),
        .DOUT(DOUT_i),
        .VOUT(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));   

endmodule

		   
