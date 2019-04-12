module transmitter_fsm (
 input wire reset, clk ,start_signal,sam_tick,
 input wire [7:0]data_in ,
 input wire [1:0]parity, // in case no parity used only 8 bit data are recieved , if parity used then 9 are recieved 
 input wire stop_bit , //1'b0 for one stop bit , 1'b1 for 2 stop bits 
 input wire bits_num , //1'b0 for 7 bit , 1'b1 for 8 bits
 
 output reg tx ,
 output reg tx_done // a tick pulse when all data is transmitted 
);

parameter idle_state= 0 , start_state= 1 , data_state=2, parity_state=3 , stop_state=4 ;
reg [2:0]state; 
reg[2:0]state_next ;
reg [7:0]data ;
reg[7:0]data_next ;
reg[4:0]counter;
reg [4:0] counter_next ;
reg [3:0]counter_b;
reg [3:0] counter_b_next ;
wire xoring, parity_bit ;
reg tx_done_next, tx_next ;

always@(posedge clk , posedge reset)
begin 
if (reset)
	begin 
 	//reseting
	tx <= 1 ;
	tx_done <= 0 ;
	state <= idle_state;
	counter <= 0 ;
	counter_b <= 0 ; 
	end 
else 
	begin 
	//updates
	tx <= tx_next ;
	tx_done <= tx_done_next ;
	state <= state_next;
	counter <= counter_next ;
	counter_b <= counter_b_next ; 
	end 

end 








//next_state logic:
always @(*)
begin 
case(state)
idle_state:
	begin
	tx_next <= 1 ; 
	tx_done_next <=0 ;
	if (start_signal) 
	begin 
		counter_next <=0 ;
		state_next <= start_state ;
		data_next <=  data_in ;
	end 

	end
start_state :
 	begin
	tx_next<=0 ;
	if (sam_tick)
	begin 
	
		if ( counter== 15)
		begin 
		state_next <= data_state ;
		counter_next <= 0 ;
		counter_b_next <= 0 ;
		end 
		else begin
		counter_next <= counter+1 ;
		end 
		
	
	end
	end
data_state :
	begin 
	tx_next <= data[0] ;
	if (sam_tick)
	begin 
	
		if ( counter== 15)
		begin 
		data_next<= data>>1; 
			if ( (counter_b == 7 && bits_num==1'b1)||(counter_b == 6 && bits_num==1'b0))
			begin
			state_next <= parity_state ;
			counter_next <=0 ;
			counter_b_next <= 0 ;
			end
			else begin counter_b_next <= counter_b + 1 ;    end 
		end 
		else begin
		counter_next <= counter+1 ;
		end 
		
	
	end	
	end
parity_state :
begin
	
	if (parity== 2'b00 || parity== 2'b11) //no parity skip this state 
	begin 
	tx_next <= 1; 
	state_next <= stop_state ;
	end 
	else 
	begin
	tx_next <= parity_bit  ;
	if (sam_tick)
	begin 
	
		if ( counter== 15)
		begin 
		state_next <= stop_state ;
		counter_next <= 0 ;
		counter_b_next <= 0 ;
		end 
		else begin
		counter_next <= counter+1 ;
		end 
		
	
	end
	end 
end
stop_state :
begin
	tx_next<=1 ;
	if (sam_tick)
	begin 
	
		if ( counter== 15)
		begin 
		
			if ( (counter_b == 0 && stop_bit==1'b0)||(counter_b == 1 && stop_bit==1'b1))
			begin
			state_next <= idle_state ;
			counter_next <=0 ;
			counter_b_next <= 0 ;
			tx_done_next<=1;
			end
			else begin counter_b_next <= counter_b + 1 ;    end 
		end 
		else begin
		counter_next <= counter+1 ;
		end 
		
	
	end
end		
endcase



end // end of alwyas block-next state logic-








assign xoring = (bits_num==1'b0)? (data_in[0]^data_in[1]^data_in[2]^data_in[3]^data_in[4]^data_in[5]^data_in[6]) : 
 (data_in[0]^data_in[1]^data_in[2]^data_in[3]^data_in[4]^data_in[5]^data_in[6]^data_in[7]) ;

assign parity_bit = (parity==2'b10)? xoring : ~xoring   ; // considering the case of even parity and the others will be directly handled 


endmodule 