module interface_transmitter (
input wire clk, reset , 
input wire [7:0]data_in, 
input wire enable_trans, // enable transmition sets the flag till transmition ends the flag is cleared by the fsm signal 
input wire tx_done ,

output reg trans_flag,
output reg [7:0] data
);

always @(posedge clk , posedge reset )
begin 

if (reset)
	begin 
	trans_flag <=0 ;
	data<=0;
	end 
else 	
	 
	begin 
	
	if ((tx_done) && (trans_flag == 1'b1 ))
		begin 
		trans_flag <=0 ;
		end 
	else if ( (enable_trans) && (trans_flag == 1'b0 ))
		begin 
		trans_flag <=1 ;
		data <= data_in ;
		end 
	else trans_flag <= 0;
	
	end  



end 


endmodule
