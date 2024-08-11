module mul (
	input [31:0] M1, M2,
	output [31:0] P,
	output Exception
);

	// Segmentation of Numbers
	wire m1_s, m2_s;
	wire [7:0] m1_exp, m2_exp;
	wire [22:0] m1_man, m2_man;

	wire p_s;
	reg [7:0] p_exp;
	reg [22:0] p_man;

	reg [8:0] exp_sub, exp_unnorm, exp_norm;
	reg [22:0] man_norm;
	reg [47:0] man_mul;

	assign m1_s = M1[31];
	assign m1_exp = M1[30:23];
	assign m1_man = M1[22:0];

	assign m2_s = M2[31];
	assign m2_exp = M2[30:23];
	assign m2_man = M2[22:0];

	assign P[31] = p_s;
	assign P[30:23] = p_exp;
	assign P[22:0] = p_man;

	// Output Number Sign
	assign p_s = m1_s ^ m2_s;

	// Exception of Invalid Numbers
	assign Exception = (&m1_exp) | (&m2_exp);

	// Exponent Unbiasing and Mantissa Multiplication
	always @(*) begin
		exp_sub = m1_exp - 8'd127;
		exp_unnorm = exp_sub[7:0] + m2_exp;
		man_mul = {1'b1, m1_man} * {1'b1, m2_man};
	end

	always @(*) begin
		// Normalization
		case (man_mul[47])
			1: begin
				exp_norm = exp_unnorm[7:0] + 1;
				man_norm = man_mul[46:24];
			end 
			default: begin
				exp_norm = exp_unnorm[7:0];
				man_norm = man_mul[45:23];
			end
		endcase

		// Final Stage
		if(({exp_sub[8], exp_sub[7], exp_unnorm[8]} == 3'b101)||	// Infinity
			(&(exp_norm[7:0]) == 1'b1)||(exp_norm[8])) begin     
				p_exp = {{7{1'b1}}, 1'b0};
				p_man = {23{1'b1}};
		end else if(({exp_sub[8], exp_unnorm[8]} == 2'b10)||		// Zero
			Exception) begin     
				{p_exp, p_man} = 0;
		end else begin
			p_exp = exp_norm[7:0];
			p_man = man_norm;
		end
	end
endmodule