module clock(clock);
	output clock;
	reg [13:0] counter = 14'b0;
	parameter DIV_FREQ = 14'd2_000;
	wire int_lfosc;
	// Oscilator
	SB_LFOSC u_SB_HFOSC(.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(int_lfosc));
	
	always @(posedge int_lfosc) 
	begin
		if(counter>=(DIV_FREQ-1'd1))
			counter = 14'd0; //LLegamos al maximo
  		else   
  			counter = counter + 1'b1;
	end

	assign clock = (counter>DIV_FREQ/2);
endmodule

