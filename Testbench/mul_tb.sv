module mul_tb;

	reg [31:0] M1, M2;
	wire [31:0] P;
	wire EX;
	shortreal n1, n2, out;

	// Connecting The Design
	mul mul(M1, M2, P, EX);

	assign M1 = n1;
	assign M2 = n2;
	assign out = P;
  
	initial $monitor(" \n \
					Inputs: \n \
					M1 = %f,\n \
					M2 = %f,\n \
					Output: \n \
					P = %f,\n \
					EX is %b",
              
					$bitstoshortreal(M1), 
					$bitstoshortreal(M2), 
					$bitstoshortreal(P),
					EX);

	// Using Various Test Values to Cover Multiple Corners
	initial begin
		n1 = 0;
		n2 = 0;
		#10;

		n1 = 32'h4234_851F; //45.13
		n2 = 32'h427C_851F; //63.13
		//2849.0569
		#10;

		n1 = 32'h4049_999A; //3.15
		n2 = 32'hC166_3D71; //-14.39
		//-45.3285
		#10;       

		n1 = 32'hC152_6666; //-13.15
		n2 = 32'hC240_A3D7; //-48.16
		//633.304
		#10;        
			
		n1 = 32'h4580_0000; //4096 
		n2 = 32'h4580_0000; //4096 
		//16777216
		#10;      
			
		n1 = 32'h3ACA_62C1; //0.00154408081
		n2 = 32'h3ACA_62C1; //0.00154408081
		//0.00000238418
		#10;

		n1 = 32'h0; //0
		n2 = 32'h0; //0
		//0
		#10;
			
            	
		n1 = 32'hC152_6666; //-13.15
		n2 = 32'h0; //0
		//0
		#10;
			
			
		n1 = 32'h7F80_0000; 
		n2 = 32'h7F80_0000; 
		//0
		#10;
   	
		n1 = 32'h0080_0000; 
		n2 = 32'h00180_000; 
		//0
		#10;      
				
		$finish;
	end
endmodule