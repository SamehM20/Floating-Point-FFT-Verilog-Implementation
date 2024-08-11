module fft4 #(localparam num_p = 4)(
	input [32*num_p-1:0] A_r, A_i,
	input [32*(num_p/2)-1:0] W_r, W_i,
	output [32*num_p-1:0] C_r, C_i,
	output Exception
);
    
	wire [31:0] y_r[$clog2(num_p):0][num_p-1:0],
				y_i[$clog2(num_p):0][num_p-1:0];
	wire [31:0] iw_r[(num_p/2)-1:0], iw_i[(num_p/2)-1:0];
	wire [$clog2(num_p)-1:0] exe0 [(num_p/2)-1:0];
	wire [$clog2(num_p)-1:0] exe1;

	assign Exception = |exe1;

	genvar ind;

	// Getting All Exceptions Together
	generate
		for (ind=0;ind<$clog2(num_p);ind=ind+1) begin
			assign exe1[ind] = |exe0[ind];       
		end
	endgenerate

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
			assign C_r[32*(ind+1)-1:32*ind] = y_r[$clog2(num_p)][ind];
			assign C_i[32*(ind+1)-1:32*ind] = y_i[$clog2(num_p)][ind];
		end
	endgenerate


	// Using Radix-2 Butterfly Unit to Calculate The Output
	genvar i;
	generate
		for (ind=1;ind<=$clog2(num_p);ind=ind+1) begin
			for (i=0;i<num_p/2;i=i+1) begin
				rad2_bf rad2 (y_r[ind-1][i], y_i[ind-1][i], 
							  y_r[ind-1][i+num_p/2], y_i[ind-1][i+num_p/2],
							  iw_r[((ind%2==0)?i:0)], iw_i[((ind%2==0)?i:0)],
							  y_r[ind][((ind%2==0)?i:2*i)], y_i[ind][((ind%2==0)?i:2*i)], 
							  y_r[ind][((ind%2==0)?i+num_p/2:2*i+1)], y_i[ind][((ind%2==0)?i+num_p/2:2*i+1)],
							  exe0[ind-1][i]);
			end
		end
	endgenerate 
endmodule