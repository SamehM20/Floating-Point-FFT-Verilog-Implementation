module rad2_bf (
	input [31:0] A_r, A_i, B_r, B_i, W_r, W_i,
	output [31:0] C1_r, C1_i, C2_r, C2_i,
	output Exception
);
	wire [31:0] BW_r, BW_i;    
	wire [31:0] B_r_W_r, B_r_W_i, B_i_W_r, B_i_W_i;    
	wire [9:0] exe;
	
	// Exception
	assign Exception = |exe;
		
	// Calculating (Br + j Bi)*(Wr + j Wi) = ((Br * Wr) - (Bi * Wi)) + j ((Br * Wi) + (Bi * Wr))
	mul m0 (.M1(B_r), .M2(W_r), .P(B_r_W_r), .Exception(exe[0]));   // (Br * Wr)
	mul m1 (.M1(B_r), .M2(W_i), .P(B_r_W_i), .Exception(exe[1]));   // (Br * Wi)
	mul m2 (.M1(B_i), .M2(W_r), .P(B_i_W_r), .Exception(exe[2]));   // (Bi * Wr)
	mul m3 (.M1(B_i), .M2(W_i), .P(B_i_W_i), .Exception(exe[3]));   // (Bi * Wi)
	
	acc a0 (.M1(B_r_W_r), .M2({~B_i_W_i[31], B_i_W_i[30:0]}), .Out(BW_r), .Exception(exe[4]));  // (Br * Wr) - (Bi * Wi)
	acc a1 (.M1(B_r_W_i), .M2(B_i_W_r), .Out(BW_i), .Exception(exe[5]));    // (Br * Wi) + (Bi * Wr)
	
	// Calculating the Output
	acc out0 (.M1(A_r), .M2(BW_r), .Out(C1_r), .Exception(exe[6])); // C1r = (Ar + ((Br * Wr) - (Bi * Wi)))
	acc out1 (.M1(A_i), .M2(BW_i), .Out(C1_i), .Exception(exe[7])); // C1i = (Ai + ((Br * Wi) + (Bi * Wr)))
	
	acc out2 (.M1(A_r), .M2({~BW_r[31], BW_r[30:0]}), .Out(C2_r), .Exception(exe[8]));  // C2r = (Ar - ((Br * Wr) - (Bi * Wi)))
	acc out3 (.M1(A_i), .M2({~BW_i[31], BW_i[30:0]}), .Out(C2_i), .Exception(exe[9]));  // C2i = (Ai - ((Br * Wi) + (Bi * Wr)))
endmodule