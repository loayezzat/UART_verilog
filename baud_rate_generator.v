module baud_rate_generator(clk,reset,bd_rate,clk_out);
	
	input clk,reset;
	input [1:0] bd_rate;
	output wire clk_out;
	
	
	//parameter clk_in = 50*(10**6);
	parameter clk_in = 15360000; //for sim. purposes
	
	localparam bd1 = clk_in/(16*1200),
				  bd2 = clk_in/(16*2400),
				  bd3 = clk_in/(16*4800),
				  bd4 = clk_in/(16*9600);
	
	reg[11:0] r_reg;
	wire[11:0] r_next;
	
	integer sel;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
			r_reg <= 0;
		else
			r_reg <= r_next;
	end
	
	always @(bd_rate)
	begin
		case(bd_rate)
			2'b00 : sel = bd1;
			2'b01 : sel = bd2;
			2'b10 : sel = bd3;
			2'b11 : sel = bd4;
			default : sel = bd1;
		endcase
	end
	
	assign r_next = (r_reg == sel) ? 0 : r_reg + 1;
	
	assign clk_out = (r_reg == sel) ? 1 : 0;
endmodule
