module interface_reciever 
(

input wire clear, // a signal comes when the system reads the buffer , so flag cleared  
input wire rx_com,
input wire [8:0]data_received,
input wire clk,reset,
input wire [1:0] parity,
input wire bits_num , //1'b0 for 7 bit , 1'b1 for 8 bits 
output reg flag, // flag of data availability 

output reg parity_error,
output wire [7:0]buffer

);
reg [7:0] data ;
wire parity_bit, xoring ;
always @(posedge clk,posedge reset,posedge rx_com , posedge clear)
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
		case (bits_num)
		1'b0 : begin data[6:0] <= data_received[6:0] ; data[7]<=0 ; end 
		default : begin data[7:0] <= data_received[7:0] ; end 
		endcase 
		flag <= 1'b1 ;
		



		case (parity )//b00 for no parity b01 for odd parity, b10 for even parity b11 behave like no parity used 
		
		2'b01:  parity_error <= ~(~xoring == parity_bit); // odd parity 

			
		2'b10:  parity_error <= ~(xoring == parity_bit);// even parity
	
		default: parity_error <= 0;
		endcase
		end // end of if the Rx_com enable
	if (clear)
		begin
		flag <=1'b0 ;
		end 

	end 

end 

assign buffer = data ;
assign xoring = (bits_num==1'b0)? (data_received[0]^data_received[1]^data_received[2]^data_received[3]^data_received[4]^data_received[5]^data_received[6]) : 
 (data_received[0]^data_received[1]^data_received[2]^data_received[3]^data_received[4]^data_received[5]^data_received[6]^data_received[7]) ;

assign parity_bit = (bits_num==1'b0)? data_received[7] : data_received[8]   ;




endmodule 
