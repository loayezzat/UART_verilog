/*configuration
parity: //b00 for no parity,  b01 for odd parity, b10 for even parity b11 behave like no parity used 
stop_bit : //1'b0 for one stop bit , 1'b1 for 2 stop bits 
bits_num : //1'b0 for 7 bit , 1'b1 for 8 bits 
*/
module receiver_top (
input wire rx , clk , reset , clear_flag,
input wire [5:0] config_reg ,//bits_num bit ,  stop bit , parity bits (2) , baudrate bits (2) 
output wire flag_parity_error,
output wire flag_data_received ,
output wire [7:0] data_exracted
);
wire tick ,bits_num, stop_bit,rec_com;
wire[1:0] parity ;
wire[1:0] bd_rate ;
wire [8:0] data_with_parity ;
assign parity = config_reg[3:2] ;
assign bd_rate = config_reg[1:0] ; 
assign stop_bit =config_reg[4];
assign bits_num =config_reg[5];

receiver_fsm fsm (clk , reset , rx , tick , parity, stop_bit ,bits_num, data_with_parity, rec_com) ;
interface_reciever interface (clear_flag,rec_com ,data_with_parity,clk, reset , parity,bits_num,flag_data_received , flag_parity_error ,data_exracted) ;
baud_rate_generator baud (clk,reset,bd_rate,tick);
endmodule 

module receiver_top_tb;
reg rx, clk , rst , clear ;
reg [5:0] config_reg ;

wire flag_parity, flag_rec ;
wire [7:0] data ;

receiver_top top (rx , clk , rst , clear, config_reg , flag_parity,flag_rec , data);

reg [199:0] testing_rx;
always
begin
#1 clk <= ~clk;
end



initial
begin
clk <=0;
config_reg <= 0 ;
rst <=1;
rx<=1;

#10
rst <=0;
clear <=1'b0;

//testing 8-bits mode with parity and 1-stopbit
#10
config_reg <= 6'b101011 ;
testing_rx <= 200'b1111111111111111111111111111111111111_010100101_0_1_101010101_0_111111111111111111111111111 ; //two frames
#10
repeat(199)
begin
#3200
rx <=testing_rx[0];
testing_rx <= testing_rx>>1;
end

//testing 8-bits mode with no parity and 1-stopbit
#10
config_reg <= 6'b100011 ;
testing_rx <= 200'b1111111111111111111111111111111111111_10100101_0_1_01010101_0_111111111111111111111 ; //two frames
#10
repeat(199)
begin
#3200
rx <=testing_rx[0];
testing_rx <= testing_rx>>1;
end

//testing 7-bits mode with parity and 1-stopbit
#10
config_reg <= 6'b001011 ;
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
config_reg <= 6'b000011 ;
testing_rx <= 200'b11111111111111111111111111111111111111_0100101_0_1_1010101_0_1111111111111111111111111 ; //two frames
#10
repeat(199)
begin
#3200
rx <=testing_rx[0];
testing_rx <= testing_rx>>1;
end


end

endmodule 