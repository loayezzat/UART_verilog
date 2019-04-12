/*configuration
parity: //b00 for no parity,  b01 for odd parity, b10 for even parity b11 behave like no parity used 
stop_bit : //1'b0 for one stop bit , 1'b1 for 2 stop bits 
bits_num : //1'b0 for 7 bit , 1'b1 for 8 bits 
config_reg = 3 2 10 =>> 10 for parity 2 for stop_bit 3 for bits_num
*/
/*
to use the transmitter please follow these steps:
set enable_trans 
keep monitoring flag till it's cleared then place next frame.
*/

module transmitter_top (
input wire clk ,tick, reset ,
input wire [7:0]data_in,
input wire enable_trans,
input wire [3:0] config_reg ,//bits_num bit ,  stop bit , parity bits (2) 


output wire trans_flag,
output wire tx
);
wire [7:0]data_reg;
wire tx_done;
wire flag ;
wire stop_bit, bits_num;
wire [1:0]parity;
interface_transmitter interface_t (clk , reset ,data_in, enable_trans, tx_done , flag, data_reg ) ;
transmitter_fsm fsm_t (clk, reset,flag ,tick, data_reg, parity, stop_bit, bits_num, tx ,tx_done); 
assign trans_flag = flag ;

assign parity = config_reg[1:0];
assign stop_bit= config_reg[2];
assign bits_num=config_reg[3] ;

endmodule 

module transmitter_top_tb ;
reg [1:0] bd_rate ; 
reg clk , reset ,enable;
wire tick , tx, flag;
reg [7:0] data ;
reg [3:0] config_reg ;
baud_rate_generator baud_t (clk,reset,bd_rate,tick);
transmitter_top top_t (clk ,tick, reset ,data,enable,config_reg , flag,tx);
reg [100:0]testing_tx;

always
begin
#1 clk <= ~clk;
end



initial
begin
clk <=0;
config_reg <= 0 ;
reset <=1 ;
enable <= 0 ;
bd_rate <= 2'b11;
#10
reset <=0;


//testing 8-bits mode with parity and 1-stopbit
#10
config_reg <= 4'b1010 ;
enable<= 1; 
data<= testing_tx[7:0] ;
while(1)
begin
#2
if(flag == 0) testing_tx = testing_tx>>8; 

end

/*repeat(199)
begin
#3200
rx <=testing_rx[0];
testing_rx <= testing_rx>>1;
end

//testing 7-bits mode with parity and 1-stopbit
#10
config_reg <= 4'b0010 ;
testing_rx <= 200'b111111111111111111111111111111111111111_10100101_0_1_01010101_0_11111111111111111 ; //two frames
#10
repeat(199)
begin
#3200
rx <=testing_rx[0];
testing_rx <= testing_rx>>1;
end


//testing 7-bits mode with no parity and 1-stopbit
#10
config_reg <= 4'b0000 ;
testing_rx <= 200'b11111111111111111111111111111111111111_0100101_0_1_1010101_0_1111111111111111111111111 ; //two frames
#10
repeat(199)
begin
#3200
rx <=testing_rx[0];
testing_rx <= testing_rx>>1;

*/
end


endmodule

