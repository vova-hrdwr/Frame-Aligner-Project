// Code your testbench here
///testbench top is the top most file, in which DUT and Verification environment are connected. 

`include "interface.sv"
`include "random_test.sv"

module top;
  
//clock and reset signal declaration
bit clk;
bit rst;
  
//clock generation
always #5 clk = ~clk;
 

  
//reset generation
initial begin
  clk     = 0;
  rst = 1;
  #10 rst = 1;
  #15 rst = 0;


  #50000 // Run for 300 time units
    $finish; // End simulation
end
  
  
  
//interface instance in order to connect DUT and testcase
inf i_inf(clk,rst);
  
//testcase instance, interface handle is passed to test 
test t1(i_inf);
  
//DUT instance, interface handle is passed to test 
frame_aligner DUT(.clk(i_inf.clk), .rx_data(i_inf.rx_data), .reset(i_inf.rst), .fr_byte_position(i_inf.fr_byte_position), .frame_detect(i_inf.frame_detect));

initial begin
$dumpfile("dump.vcd"); $dumpvars(0);
end
  
endmodule