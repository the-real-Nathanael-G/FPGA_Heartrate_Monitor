//Reduce clock speed to choose what speed the system runs at (might not be necessary)

module reduceCLK (
input wire clk,
output wire clkOut
);

int N=5; //  [50/5 = 10] -THIS IS A 10MHz CLOCK <<--------------

reg [$clog2(N)-1:0] count = 0; //Creates a register wih the exact number of bits needed to perform the following code
bit i = 1'b0; //Single 0

always_ff @(posedge clk)
begin
   if (count == N) //Have we reached N
	begin
         count <= 0; //Reset count
         i <= !i; //Toggle Output Clock state
			clkOut = i;
      end
   else
      count <= count + 1; //Increment count

end

endmodule