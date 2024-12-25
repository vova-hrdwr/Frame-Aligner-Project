// Memory interface
interface inf (input logic clk,rst);
  
  //declare the signals
  logic [7:0] rx_data;
  logic frame_detect;
  logic [3:0] fr_byte_position;

  modport DUT  (input clk, rst, rx_data, output fr_byte_position, frame_detect);
  
  //--------------------------COVERAGE--------------------------


// Sequence to detect the `0xAAFA` pattern
sequence header1;
    (rx_data == 8'hAA) ##1 (rx_data == 8'hAF);
endsequence

sequence header2;
    (rx_data == 8'h55) ##1 (rx_data == 8'hBA);
endsequence

// Property to detect two consecutive `header1` sequences
property detect_consecutive_header1;
@(posedge clk)
    // Look for `header1` followed immediately by another `header1`
    (((!frame_detect)[*26])and(((fr_byte_position == 0)and( header1 or header2)) ##11 (header1 or header2) ##11 (header1 or header2))) |-> ##2 $rose(frame_detect);
endproperty

// Assertion and Coverage for `detect_consecutive_header1`
assert_first_try: assert property (detect_consecutive_header1)
    else $error("Error: Consecutive header1 (0xAFAA) pattern not detected as expected.");


// Cover property to track coverage for the sequence occurrence
cover_first_try: cover property (detect_consecutive_header1);


  endinterface