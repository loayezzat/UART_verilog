
/*configuration
parity: //b00 for no parity,  b01 for odd parity, b10 for even parity b11 behave like no parity used 
stop_bit : //1'b0 for one stop bit , 1'b1 for 2 stop bits 
bits_num : //1'b0 for 7 bit , 1'b1 for 8 bits 
*/

module receiver_fsm

(input wire clk , reset , rx, sam_tick,
 input wire [1:0] parity, // in case no parity used only 8 bit data are recieved , if parity used then 9 are recieved 
 input wire stop_bit , //1'b0 for one stop bit , 1'b1 for 2 stop bits 
 input wire bits_num , //1'b0 for 7 bit , 1'b1 for 8 bits 
 output reg [8:0] data_out ,
 output wire complete_pulse  
);

reg rec_complete ,rec_complete_next ;
reg [8:0]data_reg, data_reg_next ;
reg [1:0]state_current, state_next;
reg [4:0]s_count, s_count_next; //sampling counter 5 bits because in case of 2 stop bits we need to count to 31.
reg [3:0]b_count,b_count_next; //data bits counter 4 bits because in case of 8 data_bits and 1 parity bit we need to count to 8 ;
parameter IDLE = 2'b00, START = 2'b01 ,DATA= 2'b10 , STOP = 2'b11 ;
parameter bits_7 = 2'b00, bits_8 = 2'b01 ,bits_9= 2'b10  ;


//frame width logic (no. of bits excluding start and stop bits)::
reg [1:0] total_no_bits ;

always @(parity,stop_bit,bits_num)
begin 
if ( ((parity == 2'b00)||(parity == 2'b11)) && (bits_num == 1'b0) ) // no parity  and 7 bits to be send
	begin total_no_bits <= bits_7 ; end 
else if ( ((parity == 2'b01)||(parity == 2'b10)) && (bits_num == 1'b1) ) // with parity and 8 bits to be send
	begin total_no_bits <= bits_9 ; end 
else 
	begin total_no_bits <= bits_8 ; end // another cases always total no. of bits is 8 


end  // end of frame width logic

//padding logic 
always @(total_no_bits,data_reg)
begin 

case (total_no_bits) 
bits_7: begin  data_out[6:0] <= data_reg[8:2] ; 
		data_out[8:7] <= 2'b00 ;

	end 

bits_8: begin data_out[7:0] <= data_reg[8:1] ; 
		data_out[8] <= 1'b0 ;

	end

bits_9: begin data_out <= data_reg;
	 end 
default : begin  data_out <= data_reg; 
	end 

endcase 


end 




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

		if ( ((b_count == 8) &&(total_no_bits==bits_9)) || ((b_count == 7) &&(total_no_bits==bits_8))||((b_count == 6) &&(total_no_bits==bits_7))   )  
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


assign complete_pulse =  rec_complete;

endmodule 


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module receiver_fsm_tb;

reg clk ,rst ,rx ;
wire [8:0] data_out;
wire complete,tick;
reg [1:0] baud_rate ;
reg stop_bit,bits_num;
reg [1:0] parity ;
//wire [7:0]data_out_wp ; //data with out parity
baud_rate_generator gen (clk,rst,baud_rate,tick);
/*
(input wire clk , reset , rx, sam_tick,
 input wire [1:0] parity, // in case no parity used only 8 bit data are recieved , if parity used then 9 are recieved 
 input wire stop_bit , //1'b0 for one stop bit , 1'b1 for 2 stop bits 
 input wire bits_num , //1'b0 for 7 bit , 1'b1 for 8 bits 
 output wire [8:0] data_out ,
 output wire complete_pulse  
);

*/
receiver_fsm RX1( clk ,rst ,rx ,tick ,parity,stop_bit,bits_num,data_out ,complete );

//interface_reciever interface (clear, complete,data_out,clk, rst,parity,flag, parity_error,data_out_wp);

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
bits_num <=0 ;
#10
rst <=0;
parity <= 2'b00;
//clear <=1'b0;
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
//#3200 rx<=1;
//parity bit
//#3200 rx<=0;
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
//#3200 rx<=1;
//parity bit
//#3200 rx<=0;
//stop bit
#3200 rx<=1;
/*
#0
$monitor("%b %b tick %b data %b %b complete %b" ,rst ,clk ,tick ,rx ,data_out ,complete);*/
end


endmodule 

