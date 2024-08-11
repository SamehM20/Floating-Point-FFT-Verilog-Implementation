module tb;
	localparam num_p = 8;

	wire [num_p-1:0][31:0] dut_A_r, dut_A_i;
	wire [(num_p/2)-1:0][31:0] dut_W_r, dut_W_i;

	wire [num_p-1:0][31:0] C_r, C_i;
	wire EX;

	shortreal A_r[num_p-1:0],
	          A_i[num_p-1:0],
	          W_r[(num_p/2)-1:0],
	          W_i[(num_p/2)-1:0];

	genvar k;
	generate
		for (k = 0; k < num_p; k=k+1) begin
			assign dut_A_r[k] = $shortrealtobits(A_r[k]);
			assign dut_A_i[k] = $shortrealtobits(A_i[k]);
		end
		for (k = 0; k < (num_p/2); k=k+1) begin
			assign dut_W_r[k] = $shortrealtobits(W_r[k]);
			assign dut_W_i[k] = $shortrealtobits(W_i[k]);
		end
	endgenerate

	// Connecting The Design
	fft8 dut (dut_A_r, dut_A_i, dut_W_r, dut_W_i, C_r, C_i, EX);

	initial begin
		integer i;
		// Initializing
		for (i=0;i<num_p;i++) begin
		    A_r[i] = 0;
		    A_i[i] = 0;
		end

		// Assigning The Twiddle Factors
		W_r[0] = 1;
		W_i[0] = 0;
			
		W_r[1] = 1/$sqrt(2);
		W_i[1] = -1/$sqrt(2);
			
		W_r[2] = 0;
		W_i[2] = -1;
			
		W_r[3] = -1/$sqrt(2);
		W_i[3] = -1/$sqrt(2);

		#10;

		// Generating Input Values
		for (i=0;i<num_p;i++) begin
			A_r[i] = 2*(i**2)/3.0-7.562;
			A_i[i] = 16*i/5.152-i**3;
		end

		// Displaying I/O Values
		#10;
		$display("Inputs:");

		for (i=0;i<num_p;i++) 
			$display(" A[%0d] = (%f, %fj)",
					i, 
					A_r[i],
					A_i[i]);

		$display("Outputs:");

		for (i=0;i<num_p;i++) 
			$display(" C[%0d] = (%f, %fj)",
					i,
					$bitstoshortreal(C_r[i]), 
					$bitstoshortreal(C_i[i]));

		if(EX) $display("Exception Found!");
		else $display("No Exceptions Found.");
		$finish;
	end
endmodule
