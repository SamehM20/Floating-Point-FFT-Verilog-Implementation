module fft8 #(localparam num_p = 8)(
	input [32*num_p-1:0] A_r, A_i,
	input [32*(num_p/2)-1:0] W_r, W_i,
	output [32*num_p-1:0] C_r, C_i,
	output Exception
);
    
	wire [31:0] y_r[2:0][num_p-1:0],
				y_i[2:0][num_p-1:0];
	wire [31:0] iw_r[(num_p/2)-1:0], 
				iw_i[(num_p/2)-1:0];

	wire [(num_p/2)+1:0] exe0;

	assign Exception = |exe0;

	genvar ind, i;

	// Assigning the Twiddle Factors
	generate
		for (ind=0;ind<num_p/2;ind=ind+1) begin
			assign iw_r[ind] = W_r[32*(ind+1)-1:32*ind];
			assign iw_i[ind] = W_i[32*(ind+1)-1:32*ind];        
		end
	endgenerate

	// Connecting Nets Array to The I/O Signals
	generate
		for (ind=0;ind<num_p;ind=ind+1) begin
			assign y_r[0][ind] = A_r[32*(ind+1)-1:32*ind];
			assign y_i[0][ind] = A_i[32*(ind+1)-1:32*ind];
			assign C_r[32*(ind+1)-1:32*ind] = y_r[2][ind];
			assign C_i[32*(ind+1)-1:32*ind] = y_i[2][ind];
		end
	endgenerate

	// Using Cooley–Tukey FFT algorithm to Calculate FFT8 Using FFT4
	generate
		for (i=0;i<2;i=i+1) begin
			fft4 f4 ({y_r[0][i+6], y_r[0][i+4], y_r[0][i+2], y_r[0][i]},
					 {y_i[0][i+6], y_i[0][i+4], y_i[0][i+2], y_i[0][i]}, 
					 {iw_r[2], iw_r[0]},
					 {iw_i[2], iw_i[0]},
					 {y_r[1][4*i+3], y_r[1][4*i+2], y_r[1][4*i+1], y_r[1][4*i]},
					 {y_i[1][4*i+3], y_i[1][4*i+2], y_i[1][4*i+1], y_i[1][4*i]},
					 exe0[(num_p/2)+i]);
		end
	endgenerate 

	// Using Radix-2 Butterfly Unit to Calculate The Output
	generate
		for (ind=1;ind<$clog2(num_p)-1;ind=ind+1) begin
			for (i=0;i<num_p/2;i=i+1) begin
				rad2_bf rad2 (y_r[ind][i], y_i[ind][i], 
							  y_r[ind][i+num_p/2], y_i[ind][i+num_p/2],
							  iw_r[i], iw_i[i],
							  y_r[ind+1][i], y_i[ind+1][i], 
							  y_r[ind+1][i+num_p/2], y_i[ind+1][i+num_p/2],
							  exe0[i]);
			end
		end
	endgenerate 
endmodule