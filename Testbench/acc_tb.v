module acc_tb;

	reg [31:0] M1, M2;
	wire [31:0] Out;
	wire EX;
	shortreal n1, n2, out;

	// Connecting The Design
	acc acc(M1, M2, Out, EX);

	assign M1 = n1;
	assign M2 = n2;
	assign out = Out;
	
	initial $monitor(" \n \
					Inputs: \n \
					M1 = %f,\n \
					M2 = %f,\n \
					Output: \n \
					Out = %f \n \
					Exception: %b",
	            
					$bitstoshortreal(M1), 
					$bitstoshortreal(M2), 
					$bitstoshortreal(Out),
					EX);

	// Using Various Test Values to Cover Multiple Corners
	initial begin
		n1 = 0;
		n2 = 0;
		#10;

		n1 = 32'h4201_51EC; //32.33
		n2 = 32'h4242_147B; //48.52
		// 80.85
		#10;
		
		n1 = 32'h4068_51EC; //3.63
		n2 = 32'h4090_A3D7; //4.52
		//8.15
		#10;       

		n1 = 32'h4542_77D7; //3111.49
		n2 = 32'h453B_8FD7; //3000.99
		//6112.48
		#10;        
				
		n1 = 32'h3F3A_E148; //0.73 
		n2 = 32'h3EB33333;  //0.35 
		//1.08
		#10;      
				
		n1 = 32'h4B7F_FFFF; //16777215 
		n2 = 32'h3F80_0000; //1
		//16777216
		#10;      	

		n1 = 32'h4B7F_FFFF; //16777215 
		n2 = 32'h4000_0000; //2
		//16777217
		#10;

		n1 = 32'hBF3A_E148; //-0.73
		n2 = 32'h3EC7_AE14; //0.39 
		//-0.34
		#10;


		n1 = 32'hC207_C28F; //-33.94
		n2 = 32'h4243_B852; //48.93
		//14.99
		#10;


		n1 = 32'h4E6B_79A3; //987654321 
		n2 = 32'hCCEB_79A3; //-123456789
		//864197532
		#10;


		n1 = 32'h7F80_0000; 
		n2 = 32'h3EC7_AE14; 
		//0
		#10;
		$finish;
	end
endmodule