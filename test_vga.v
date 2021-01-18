module test_vga
(
	// outputs
	output wire gpio_12, //h_sync
	output wire gpio_21, //v_sync
	output wire gpio_13, //R
	output wire gpio_19, //G
	output wire gpio_18, //B
	output wire gpio_28 //clock_test
);
	//Entradas y salidas
	wire h_sync_out = gpio_12;
	wire v_sync_out = gpio_21;
	wire R = gpio_13;
	wire G = gpio_19;
	wire B = gpio_18;
	wire clk_pixel = gpio_28;
	//assign gpio_28 = clk_pixel;

	wire visible;
	wire [9:0] row;
	wire [9:0] col;
	wire CLKHF;
	wire lock_signal;

	wire half_sec_clk;
	//seteo clock 0.5sec
	clock myClock(.clock(half_sec_clk));

	//seteo clock - 48MHz
	SB_HFOSC OSCInst0(.CLKHFEN(1'b1),.CLKHFPU(1'b1),.CLKHF(CLKHF));
	 /* synthesis ROUTE_THROUGH_FABRIC= [0|1] */

	//Usando PLL para bajarlo a 25MHZ
	mypll mypll_inst(.REFERENCECLK(CLKHF),
                 	 .PLLOUTCORE(clk_pixel),
                 	 .PLLOUTGLOBAL(),
                 	 .RESET(1'b1),
                 	 .LOCK(lock_signal)); //lock es activo alto


	//controlador
	vga_controller GPU(.pixel_clk(clk_pixel),.visible(visible),.row(row),.col(col),.h_sync(h_sync_out),.v_sync(v_sync_out),.reset(1'b0));												 
																   
	
	// dibujando un borde
	wire vga_R = (row[9:3]==0) || (row[9:3]==20) || (row[9:3]==50) || (col[8:3]==20) || (col[8:3]==36) || (row[9:3]==79) || (col[8:3]==0) || (col[8:3]==59);
	wire vga_G = (row[9:3]==0) || (col[9:3]==10) || (col[9:3]==55) || (row[8:3]==29) || (row[8:3]==36) || (row[9:3]==79) || (col[8:3]==0) || (col[8:3]==59);
	wire vga_B = (row[9:3]==0) || (row[9:3]==20) || (col[9:3]==50) || (col[8:3]==40) || (col[8:3]==67) || (row[9:3]==79) || (col[8:3]==0) || (col[8:3]==59);
	assign R = vga_R;
	assign G = vga_G;
	assign B = vga_B;


	// reg vga_R, vga_G, vga_B;
	// reg [1:0] count = 2'b0;
	// always @(posedge half_sec_clk)
	// begin
	// 	case (count)
	//   		2'b00: begin
	// 				vga_R = (col[3] | (row==256));
	// 				vga_G = 0;
	// 				vga_B = 0;
	// 			   end
	//   		2'b01: begin
	// 				vga_R = 0;
	// 				vga_G = ((row[5] ^ row[6]) | (row==256));
	// 				vga_B = 0;
	// 			   end
	//   		2'b10: begin
	// 				vga_R = 0;
	// 				vga_G = 0;
	// 				vga_B = (row[4] | (row==256));
	// 			   end
	//   		default: begin
	// 					vga_R = 0;
	// 					vga_G = 0;
	// 					vga_B = 0;
	// 			   	end
	// 	endcase

	// end

	// assign R = (visible==1)? vga_R:0;
	// assign G = (visible==1)? vga_B:0;
	// assign B = (visible==1)? vga_G:0;

endmodule
