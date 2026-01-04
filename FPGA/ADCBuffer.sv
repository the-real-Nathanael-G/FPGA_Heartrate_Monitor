//Looking at the datasheet for the ADC chip, it appears that the chip takes 4 clock cycles to decipher the analogue input
 //signal and then the next 12 are for passing on the digital data bit by bit, taking 16 clock cycles total. The first 4 cycles
  //will give an output of 0 from the chip, which can be ignored as we only need the data from the last 12 cycles.
   //These 12 cycles then need to be taken and passed on to the MCU. The ADC and this module work with a 50MHz clock
	 //but we only want to sample at a rate of 1MHz. The ADC starts sampling at the falling edge of chip select (Output cs). This
	  //buffer needs to write the data as it comes in, then set cs HIGH after all the data has arrived. The buffer will then
	   //send the array of data it has collected through the output dataOut, one bit at a time, adding 12 more cycles to the run
		 //time, for a total of 28 clock cycles to set cs HIGH, write the data and then read it back to the MCU.


module ADCBuffer (
   input wire clk,
   input wire adcData,
   output reg [15:0]dataOut,
   output wire CSOut
);

int N=250000; //  [50M/250k = 200], 200Hz <<--------------
//int size = $clog2(N)-1; //Size of freqCount register to ensure it always has enough space regardless of what value N is
//reg [size:0] freqCount = 5'110010;
int freqCount = 249999; //Creates a register wih the exact number of bits needed keep track of the frequency counter

//Internal signals
reg [15:0] buffer = 16'b0; //Array for the data stored in this Buffer
reg [4:0] writePtr = 5'b00000; //Pointer for the Write cycle
reg [4:0] readPtr = 5'b00000; // Pointer for the Read cycle
reg [4:0] count = 5'b00000; //Counter for Buffer
reg bufferFull = 1'b0; //Flag to see if the buffer has been filled
bit cs = 1'b1; //Starts HIGH, only LOW when we want to do something
bit bitToSend; //Buffer data is sent to MCU bit-by-bit

assign CSOut = cs; //Set the output to hold the value we set in the following code
//assign dataOut = bitToSend; //Send the current bit that is being read
assign dataOut = buffer; //Send the current bit that is being read

always_ff @(posedge clk) begin
	
	
	//ADC is started, write incoming data following along with the ADC timing
	if ((cs === 1'b0) && (bufferFull == 1'b0)) begin //Only collect data for last 12 cycles
		buffer[writePtr] <= adcData; //Buffer write
		writePtr <= writePtr + 1'b1;
				
		if (count >= 5'b01111) begin //Data collection is complete
			bufferFull <= 1'b1; //Buffer is full, we do not want to repeat the write segment
			count <= 5'b00000; //Reset count
			writePtr <= 5'b00000; //Reset pointer
			cs <= 1'b1; //After Buffer has been filled, set chip select HIGH again to stop ADC from running
		end else
			count <= count + 1'b1;
	end

	
	//Buffer read
	if ((cs == 1'b1) && (bufferFull == 1'b1)) begin
		//bitToSend <= buffer[readPtr]; //Output the current bit of data
		bufferFull <= 1'b0; //Reset Buffer flag so we can write to it again
		
		/*if (readPtr >= 5'b10000) begin //We have read all 12 values
			readPtr <= 5'b00000; //Reset Read pointer
			bufferFull <= 1'b0; //Reset Buffer flag so we can write to it again
			bitToSend <= 1'b0;
		end else
			readPtr <= readPtr + 1'b1; //Move read pointer to the next position
		*/
	end

	//This IF statement triggers cs every 10MHz
   if (freqCount >= N) begin //Have we reached N
         freqCount = 0; //Reset count
         cs <= 1'b0; //Set chip select LOW to begin ADC
   end else
      freqCount <= freqCount + 1; //Increment count


end
endmodule

