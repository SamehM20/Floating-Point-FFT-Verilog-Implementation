module acc (
	input [31:0] M1, M2,
	output reg [31:0] Out,
	output reg Exception
);

	reg eq_e, gr_e, gr_m;   // Flags of equal and M1>M2 Exponents, and M1>M2 Mantissa
	reg [31:0] big, sml;    // Identified and Swapped numbers

	// Segmentation of Swapped Numbers
	wire big_s, sml_s;
	wire [7:0] big_exp, sml_exp;
	wire [22:0] big_man, sml_man;

	assign big_s = big[31];
	assign big_exp = big[30:23];
	assign big_man = big[22:0];

	assign sml_s = sml[31];
	assign sml_exp = sml[30:23];
	assign sml_man = sml[22:0];


	reg [7:0] ex_dif;       // Exponents Difference
	reg [23:0] sml_sh_man;  // Smaller Number Shifted Mantissa
	reg [23:0] sml_sh_acc;  // Input to The Accumulator from The Smaller Number
	reg [24:0] acc;         // Accumulator Output
	reg [4:0] shft;         // Normalization Shifting Factor

	reg norm_s;
	reg [7:0] norm_exp;     // Normalised Exponent
	reg [22:0] norm_man;    // Normalised Mantissa
	reg cin, carry;         // Exponent Normalization Flags
	reg [7:0] norm_exp_add;


	// Swapping Numbers
	always @(*) begin
		// Checking Which is Bigger
		eq_e = (M1[30:23] == M2[30:23])? 1'b1: 1'b0;
		gr_e = (M1[30:23] > M2[30:23])? 1'b1: 1'b0;
		gr_m = (M1[22:0] > M2[22:0])? 1'b1: 1'b0;

		if (gr_e || (eq_e & gr_m)) begin
			big = M1;
			sml = M2;
		end else begin
			big = M2;
			sml = M1;
		end
	end


	// Shifting and Accumulation Process
	always @(*) begin
		// Shifting The Smaller
		ex_dif = big_exp - sml_exp;
		sml_sh_man = {1'b1, sml_man} >> ex_dif;

		// Accumulation process 
		if((big_s^sml_s))  sml_sh_acc = ~sml_sh_man;
		else               sml_sh_acc = sml_sh_man;
				
		acc = {1'b1, big_man} + sml_sh_acc + (big_s^sml_s);
	end

	// Normalisation
	integer i;
	always @(*) begin
		shft = 5'd23;
		for (i = 1; i<24; i=i+1) begin 
			if(acc[i]) shft = 5'd23 - i;
		end
	end

	always @(*) begin
		if(acc[24] && (big_s ~^ sml_s)) begin
			norm_man = acc >> 1;    
			cin = 0;
			norm_exp_add = 1;        
		end else begin
			norm_man = acc << shft;  
			cin = 1;
			norm_exp_add = ~shft;          
		end
		// Exponent Normalization
		{carry, norm_exp} = big_exp + norm_exp_add + cin;
	end

	// Final Stage
	always @(*) begin
		if (big_exp == {8{1'b1}}) Exception = 1;
		else Exception = 0;

		if((acc[24]==1) && (big_exp==5'b11110))         // Infinity 
			Out = {big_s, {7{1'b1}}, 1'b0, {23{1'b1}}}; 
		else if(((~carry) && (big_s^sml_s))||Exception) // Zero
			Out = 0;  
		else
			Out = {big_s, norm_exp, norm_man};
	end

endmodule