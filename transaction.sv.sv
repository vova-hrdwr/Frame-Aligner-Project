class transaction;  // Declare transaction class

  // Declare the transaction fields
  logic [7:0] rx_data; // Randomize the input for the DUT
  logic frame_detect; // The output of the design
  logic [3:0] fr_byte_position; // The output of the design
  
  // Constructor to initialize the transaction object
  function new();
    // Initialize or set default values if needed
  endfunction
  
  // Display function for input (rx_data)
  function void display_in(string name);
    $display("-------------------------");
    $display("- %s, time is:%t", name, $time);
    $display("-------------------------");
    $display("- rx_data = %d", rx_data);
    $display("-------------------------");
  endfunction
  
  // Display function for output (frame_detect, fr_byte_position)
  function void display_out(string name);
    $display("-------------------------");
    $display("- %s, time is:%t", name, $time);
    $display("-------------------------");
    $display("- frame_detect = %d, fr_byte_position=%d", frame_detect, fr_byte_position);
    $display("-------------------------");
  endfunction
  
endclass