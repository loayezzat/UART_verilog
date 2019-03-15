module receiver_fsm
#( parameter DATA_N = 9 ,// data bits + parity bit ; exlude start and stop bits.
   parameter STOP_BITS = 1 ,
   parameter PARITY = 1  //0 for no parity, 1 for odd parity, 2 for even parity assigning parity_error = 1; in case of error.
)

(input wire clk , reset , rx, sam_tick,
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
		//no need to reset counters as we reset them before using
		s_count <=0 ;
		b_count <=0 ;
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
			if (b_count == DATA_N-1 )
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
		if(s_count == (16*STOP_BITS-1))
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

reg clk ,rst ,rx ,tick;
wire [8:0] data_out;
wire complete;

initial
begin
clk <=0;
tick<=0;
rst <=1;
rx<= 1 ;
#20000
rst <=0;
end

always
begin
#10_000 clk <= ~clk;
end

always
begin
#60_000 tick <= ~tick;
end

initial
begin

//first frame
rx<=1;
#480_000 rx<=0;
//start of data
#480_000 rx<=1;
#480_000 rx<=1;
#480_000 rx<=0;
#480_000 rx<=1;
#480_000 rx<=0;
#480_000 rx<=1;
#480_000 rx<=0;
#480_000 rx<=1;

//parity bit
#480_000 rx<=0;
//stop bit
#480_000 rx<=1;
#480_000 rx<=1;
#480_000 rx<=1;

//secondframe
#480_000 rx<=1;
#480_000 rx<=0;
//start of data
#480_000 rx<=1;
#480_000 rx<=0;
#480_000 rx<=1;
#480_000 rx<=0;
#480_000 rx<=1; 
#480_000 rx<=1;
#480_000 rx<=1;
#480_000 rx<=0;
//parity bit
#480_000 rx<=0;
//stop bit
#480_000 rx<=1;

$monitor("%b %b tick %b data %b %b complete %b" ,rst ,clk ,tick ,rx ,data_out ,complete);
end

receiver_fsm RX1( clk ,rst ,rx ,tick ,data_out ,complete );

endmodule 