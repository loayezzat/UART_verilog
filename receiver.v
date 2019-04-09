module receiver_fsm

(input wire clk , reset , rx, sam_tick,
 input wire [1:0] parity, // in case no parity used only 8 bit data are recieved , if parity used then 9 are recieved 
 input wire stop_bit , //1'b0 for one stop bit , b1 for 2 stop bits 
 output wire [8:0] data_out ,
 reg rec_complete 
);

reg rec_complete_next ;
reg [8:0]data_reg, data_reg_next ;
reg [1:0]state_current, state_next;
reg [4:0]s_count, s_count_next; //sampling counter 5 bits because in case of 2 stop bits we need to count to 31.
reg [3:0]b_count,b_count_next; //data bits counter 4 bits because in case of 8 data_bits and 1 parity bit we need to count to 8 ;
parameter IDLE = 2'b00, START = 2'b01 ,DATA= 2'b10 , STOP = 2'b11 ;

//first block
always @(posedge clk , posedge reset )
begin 
	if (reset) 
		begin 
		state_next <= IDLE ;
		rec_complete  <= 0 ;
		data_reg <=0; 
		s_count <= 0;  
		b_count <= 0;  
		//no need to reset counters as we reset them before using

		end 
	else 
		begin 
		state_current <= state_next; 
                s_count <= s_count_next;
		b_count <= b_count_next;
		data_reg<= data_reg_next;
		rec_complete <= rec_complete_next ;
		end
end 


// next state logic block
always@(*)
begin

case (state_current)
IDLE :  begin
	rec_complete_next <= 0;
	if (rx == 0 ) 
	begin 
	s_count_next <= 0 ;
	state_next <= START;	
	end 
	end // end of IDLE case

START :
	if (sam_tick ==1)
	begin
		if(s_count==7) 
		begin
		s_count_next<= 0 ;
		state_next <= DATA;
		b_count_next<=0 ;
		end
		else s_count_next <= s_count +1 ; 
	end

DATA : 
	if (sam_tick ==1)
	begin 
		if(s_count == 15) 
		begin
		s_count_next<= 0 ;
		
		data_reg_next = {rx, data_reg[8:1]} ;

		if ( ((b_count == 8) && (parity == 2'b10 || parity == 2'b01)) ||((b_count == 7) && (parity == 2'b00 || parity == 2'b11) ) ) // parity is used , // parity is not used 
			begin 
			state_next <= STOP ;
			end
			else b_count_next <= b_count +1 ; 


		end
		else s_count_next <= s_count +1 ; 
		
	
	end

STOP: 
	if (sam_tick ==1)
	begin 
		if  ( ( (s_count ==15) && (stop_bit == 1'b0) )  || ( (s_count == 31) && (stop_bit == 1'b1) )   ) /*one stop bit */ /*two stop bit */
		begin  
		state_next <= IDLE ;
		rec_complete_next <=1 ; 
		end 
		else s_count_next = s_count+1 ;


	end 


endcase 
end // end of always block - next state logic -

assign data_out = data_reg ;
endmodule 


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module receiver_fsm_tb;

reg clk ,rst ,rx ;
wire [8:0] data_out;
wire complete,tick,flag,parity_error;
reg [1:0] baud_rate ;
reg clear ,stop_bit;
reg [1:0] parity ;
wire [7:0]data_out_wp ; //data with out parity
baud_rate_generator gen (clk,rst,baud_rate,tick);
receiver_fsm RX1( clk ,rst ,rx ,tick ,parity,stop_bit,data_out ,complete );
interface_reciever interface (clear, complete,data_out,clk, rst,parity,flag, parity_error,data_out_wp);

always
begin
#1 clk <= ~clk;
end



initial
begin
clk <=0;
baud_rate = 2'b11 ;
rst <=1;
rx<=1;
stop_bit <= 0 ;
#10
rst <=0;
parity <= 2'b01 ;
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

