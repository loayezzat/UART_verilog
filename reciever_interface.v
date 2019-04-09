module interface_reciever 
(

input wire clear, // a signal comes when the system reads the buffer , so flag cleared  
input wire rx_com,
input wire [8:0]data_received,
input wire clk, reset,
input wire [1:0] parity,
output reg flag, // flag of data availability 
output reg parity_error,
output wire [7:0]data_out
);
reg [7:0] data ;
wire xoring ;
always @(posedge clk, posedge reset)
begin 
if (reset)
	begin 
	parity_error <= 0 ;
	data <= 0 ; 
	flag <=0; 
	end 
else
	begin
	if (rx_com)
 		begin
		data <= data_received[7:0] ;
		flag <= 1'b1 ;
		case (parity )//b00 for no parity b01 for odd parity, b10 for even parity b11 behave like no parity used 

		2'b00: parity_error <= 0;
		2'b01: parity_error <= ~(~xoring == data_received[8]); // odd parity 
		2'b10: parity_error <= ~(xoring == data_received[8]);// even parity
		2'b11: parity_error <= 0;
		endcase
		end
	if (clear)
		begin
		flag <=1'b0 ;
		end 

	end 

end 
assign xoring =  (data_received[0]^data_received[1]^data_received[2]^data_received[3]^data_received[4]^data_received[5]^data_received[6]^data_received[7]) ; 
assign data_out = data ;
endmodule 
