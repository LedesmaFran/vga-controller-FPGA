/*VGA CONTROLLER		  							 
********************************************************
VGA Signal 640 x 480 @ 60 Hz Industry standard timing
General timing
Screen refresh rate	60 Hz
Vertical refresh	31.46875 kHz
Pixel freq.	25.175 MHz
Horizontal timing (line)
Polarity of horizontal sync pulse is negative.
Scanline part	Pixels	Time [µs]
Visible area	640		25.422045680238
Front porch		16		0.63555114200596
Sync pulse		96		3.8133068520357
Back porch		48		1.9066534260179
Whole line		800		31.777557100298

Vertical timing (frame)
Polarity of vertical sync pulse is negative.
Frame part		Lines	Time [ms]
Visible area	480		15.253227408143
Front porch		10		0.31777557100298
Sync pulse		2		0.063555114200596
Back porch		33		1.0486593843098
Whole frame		525		16.683217477656
*********************************************************
*/
/*
vga controller
recibe:
	*pixel_clk: clock por cada pixel
	*reset: activo alto, pone visible=row=col=0, h_sync=v_sync=1
devuelve:
	*visible: activo alto, si se encuentra en la zona visible de la pantalla
	*row,col: dos arreglos de 10bits c/u con la direccion actual
	*h y v sync: activo bajo, seniales de sincronismo.
*/
module vga_controller(pixel_clk,visible,row,col,h_sync,v_sync,reset);
	input pixel_clk;
	input reset;
	output visible;
	output [9:0] row;
	output [9:0] col;
	output h_sync;
	output v_sync;
	
	reg [9:0] row_reg = 10'b0000000000;
	reg [9:0] col_reg = 10'b0000000000;

	
	//VGA sync parameters
	parameter H_VISIBLE_AREA  	 = 640; // horizontal display area
	parameter H_FRONT_PORCH   	 =  16; // horizontal right border
	parameter H_BACK_PORCH	  	 =  48; // horizontal left border
	parameter H_SYNC_PULSE    	 =  96; // horizontal retrace
	parameter H_MAX           	 = H_VISIBLE_AREA + H_FRONT_PORCH + H_BACK_PORCH + H_SYNC_PULSE - 1;
	parameter START_H_SYNC_PULSE = H_VISIBLE_AREA + H_FRONT_PORCH;
	parameter END_H_SYNC_PULSE   = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE - 1;
	
	parameter V_VISIBLE_AREA  	 = 480; // vertical display area
	parameter V_FRONT_PORCH   	 =  10; // vertical right border
	parameter V_BACK_PORCH	  	 =  33; // vertical left border
	parameter V_SYNC_PULSE    	 =  2; // vertical retrace
	parameter V_MAX           	 = V_VISIBLE_AREA + V_FRONT_PORCH + V_BACK_PORCH + V_SYNC_PULSE - 1;
	parameter START_V_SYNC_PULSE = V_VISIBLE_AREA + V_FRONT_PORCH;
	parameter END_V_SYNC_PULSE   = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE - 1;
	
	
	wire line_filled = (row_reg==H_MAX);
	wire column_filled = (col_reg==V_MAX);
	
	//Contador para moverme por la matriz de pixel
	always @(posedge pixel_clk)
	begin
		if(line_filled)
		begin
		  row_reg <= 10'b0000000000;
		  if(column_filled)
			col_reg <=10'b0000000000;
		  else
		  	col_reg <= col_reg + 1'b1;
		end
		else
		  row_reg <= row_reg + 1'b1;
	end 
	
	
			
	//output signals
	assign row = (reset==1'b1)?10'b0000000000:row_reg;
	assign col = (reset==1'b1)?10'b0000000000:col_reg;
	
	//comparadores para generar output signal
	assign visible = (reset==1'b1)?1'b0:((row < H_VISIBLE_AREA) & (col < V_VISIBLE_AREA));
	assign h_sync = (reset==1'b1)?1'b1:~((row >= START_H_SYNC_PULSE) & (row <= END_H_SYNC_PULSE));
	assign v_sync = (reset==1'b1)?1'b1:~((col >= START_V_SYNC_PULSE) & (col <= END_V_SYNC_PULSE));
			
endmodule