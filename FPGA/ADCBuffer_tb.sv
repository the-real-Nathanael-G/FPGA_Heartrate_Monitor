
module ADCBuffer_tb;

    //Parameters
    parameter CLK_PERIOD = 20; // Clock period in ns

    //Signals
    logic clk = 0;
    logic adcData;
    reg [15:0] dataOut;
    logic CSOut;

    //Registers
    reg signed [15:0] dataStore;

    //Instantiate ADCBuffer module
    ADCBuffer adc_buffer (
        .clk(clk),
        .adcData(adcData),
        .dataOut(dataOut),
        .CSOut(CSOut)
    );

    //Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    //Test sequence
    initial begin
	for(int j = 1; j <=8; j++) begin //Repeat for 8 samples of ADC signal
		$display("\nSample %d", j);

        	//Reset signals
        	adcData = 1'b0;
		dataStore = 16'b0;

        	//Check that CS starts as 1
        	#CLK_PERIOD assert (CSOut == 1'b1) $display("CSOut == 1: %b. Test Passed", CSOut); else $error("CSOut == 1: %b. Test Failed", CSOut);

        	//Check that CSOut goes low
        	#CLK_PERIOD assert (CSOut == 1'b0) $display("CSOut == 0: %b. Test Passed", CSOut); else $error("CSOut == 0: %b. Test Failed", CSOut);


       		//Send 4 bits of 0 on the input line (adcData is set to 0 so waiting 4 clock cycles will send the appropriate signal)
		//#(CLK_PERIOD*4); //Wait for 4 clock cycles
		for (int i = 0; i < 4; i++) begin
            		#CLK_PERIOD dataStore[i] <= 1'b0;
	    		//#CLK_PERIOD;
        	end

        	//Send 12 bits of random data
        	for (int i = 4; i < 16; i++) begin
            		adcData <= $urandom_range(1); //Send a random bit
	    		#CLK_PERIOD dataStore[i] <= adcData; //Store the data we sent so we can cross check later
	    		//#CLK_PERIOD; // Wait for one clock cycle
        	end

		//Assert CSOut goes high again
        	assert (CSOut == 1'b1) $display("CSOut == 1: %b. Test Passed", CSOut); else $error("CSOut == 1: %b. Test Failed", CSOut);
		
		//Assert correct for all bits of data
            	#CLK_PERIOD assert (dataOut === dataStore) $display("Input: [%b] Output: [%b]. Test Passed", dataStore, dataOut); else $error("Input: [%b] Output: [%b]. Test Failed", dataStore, dataOut);

		

		#(CLK_PERIOD*(250000-18));//Wait until next sample. Sample is taken every 250k cycles - the 18 it took to run this previous sample.

	end
        
    end
endmodule

