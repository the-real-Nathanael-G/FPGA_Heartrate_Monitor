module display_controller (
   output logic [7:0] data,
   output logic rs,
   output logic rw,
   output logic e,
   input logic [7:0] ascii_data,
   input logic write,
   input logic clk,
	input logic reset
	);

// You might want to write your LCD controller here?

int unsigned timer, ascii_array;
logic [7:0] ascii[3:0];
int x;

typedef enum int unsigned{
	Rise_set = 0 , Func_1, Func_2, Func_3, Disp_ON_OFF, Disp_clear, Disp_clear_2, Entry, Write, Ready, Hold, Shift
} state_t;

state_t state;

 
always_ff @(posedge clk or negedge reset) begin
	if(~reset) begin
		timer <= 0;
		state <= Rise_set;
	end
	
	else begin
		timer <= timer +1;
	
	
		case(state)
		
			Rise_set: begin
				if(timer >= 4000000)begin
					timer <= 0;
					e <= 0;
					rs <= 0;
					rw <= 0;
					data <= 8'b0000_0000;
					state = Func_1;
				end
			end
			
			Func_1: begin
				if(timer < 3500)begin
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b0011_1000; 
				end
					
				else begin
					e <=0;
				end
				
				if(timer >= 35000)begin
					timer <= 0;
					state = Disp_ON_OFF;
				end
				
			end
			
			Func_2: begin
				if(timer >= 3500)begin
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b0011_1000;
				end

				else begin
					e <=0;
				end
				
				if(timer >= 35000)begin
					timer <= 0;
					state = Func_3;
				end
				
			end
			
			Func_3: begin
				if(timer < 3500)begin
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b0011_1000;
				end

				else begin
					e <=0;
				end
				
				if(timer >= 35000)begin
					timer <= 0;
					state = Disp_ON_OFF;
				end
				
			end
			
			Disp_ON_OFF: begin
				if(timer < 3500)begin
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b0000_1110;
				end
				
				else begin
					e <= 0;
				end
				
				if(timer >= 35000)begin 
					timer <= 0;
					state = Disp_clear;
				end
				
			end
			
			Disp_clear: begin
				if(timer < 10000)begin
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b0000_0001;
				end
				
				else begin
					e <= 0;
				end
				
				if(timer >= 100000)begin
						timer <= 0;
						state = Entry;
				end
			
			end
			
			Entry:begin
				if(timer < 3500)begin
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b0000_0110;
				end
				
				else begin
					e <= 0;
				end
				
				if(timer >= 35000)begin 
					timer <= 0;
					state = Ready;
					x <= 1;
				end
			
			end
			
			Ready: begin
				if(timer < 3500)begin
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b1000_0000;
				end

				else begin
					e <=0;
				end
				
				if(timer >= 35000)begin
					timer <= 0;
					state = Write;
				end
				
			end
			
			Disp_clear_2: begin
				if(timer < 10000)begin //2ms
					e <= 1;
					rs <= 0;
					rw <= 0;
					data <= 8'b0000_0001;
				end
				
				else begin
					e <= 0;
				end
				
				if(timer >= 100000)begin //20ms
						timer <= 0;
						state = Entry;
				end
			
			end
								
			Write: begin
				if(timer < 3500)begin
					e <=1;
					rs <=1;
					rw <=0;
					data = ascii_data;
					
				end
				
				else begin
					e <=0 ;
				end
				
				if(timer >= 35000)begin 
					timer <=0;
					state = Hold;
					
				end
				
			end
			
			Shift: begin
				if(timer < 3500)begin //70 us
					e <=1;
					rs <=1;
					rw <=0;
					data = 8'b0001_1100;
				end
				
				else begin
					e <=0 ;
				end
				
				if(timer >= 35000)begin //7ms
					timer <=0;
					state = Hold;
					
				end
				
			end
			
			Hold: begin
				if(timer >= 5000000)begin //100ms
					timer <= 0;
					state = Disp_clear_2;
				end
			end
		
				
		endcase
	
	end
	end
endmodule
   
