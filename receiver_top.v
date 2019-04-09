
module receiver_top (
input wire rx , clk , reset , clear_flag,
input wire [4:0] config_reg ,// stop bit , parity bits (2) , baudrate bits (2) 
output wire flag_parity_error,
output wire flag_data_received ,
output wire [7:0] data_exracted
);
wire tick , stop_bit,rec_com;
wire[1:0] parity ;
wire[1:0] bd_rate ;
wire [8:0] data_with_parity ;
assign parity = {config_reg[3],config_reg[2] } ;
assign bd_rate ={config_reg[1],config_reg[0] } ; 
assign stop_bit =config_reg[4];
receiver_fsm fsm (clk , reset , rx , tick , parity, stop_bit ,data_with_parity, rec_com) ;
interface_reciever interface (clear_flag,rec_com ,data_with_parity,clk, reset , parity,flag_data_received , flag_parity_error ,data_exracted) ;
baud_rate_generator baud (clk,reset,bd_rate,tick);
endmodule 

module receiver_top_tb;
reg rx, clk , rst , clear ;
reg [4:0] config_reg ;

wire flag_parity, flag_rec ;
wire [7:0] data ;

receiver_top top (rx , clk , rst , clear, config_reg , flag_parity,flag_rec , data);




always
begin
#1 clk <= ~clk;
end



initial
begin
clk <=0;
config_reg <= 5'b00111 ;
rst <=1;
rx<=1;

#10
rst <=0;
clear <=1'b0;
//first frame

#3200 
rx<=0;
//start of data

#3200 rx<=1;
#3200 rx<=0;
#3200 rx<=1;
#3200 rx<=0;
#3200 rx<=0;
#3200 rx<=1;
#3200 rx<=0;
#3200 rx<=1;
//parity bit
#3200 rx<=0;
//stop bit
 #3200 rx<=1;

//secondframe 
#3200 rx<=0;
//start of data
#3200 rx<=0;
#3200 rx<=1;
#3200 rx<=1;
#3200 rx<=1;
#3200 rx<=1; 
#3200 rx<=1;
#3200 rx<=1;
#3200 rx<=1;
//parity bit
#3200 rx<=0;
//stop bit
#3200 rx<=1;
/*
#0
$monitor("%b %b tick %b data %b %b complete %b" ,rst ,clk ,tick ,rx ,data_out ,complete);*/
end

endmodule 