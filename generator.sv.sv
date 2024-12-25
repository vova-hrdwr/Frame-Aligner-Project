class generator;
  
  //declare transaction class 
  transaction trans;
  
  //repeat count, to indicate number of items to generate
  int unsigned repeat_count;
  
  //declare mailbox, to send the packet to the driver
  mailbox gen2drv;
  
  //declare event, to indicate the end of transaction generation
  event ended;
  
   //declare frame_item class
  frame_item frame;
  
  //constructor
  function new(mailbox gen2drv);
    
    //get the mailbox handle from env, in order to share the transaction packet 
    //between the generator and the driver the same mailbox is shared between both.
    this.gen2drv = gen2drv;
    frame = new();
  endfunction
  
  //main task, generates (create and randomizes) the repeat_count 
  //number of transaction packets and puts them into the mailbox

  task main();
    repeat(repeat_count) begin
      if (!frame.randomize()) 
  $fatal("Gen: frame randomization failed");
      //trans.display_in("[ --Generator-- ]");
      
      //Inserting the frame. Each negedge clk the driver recieve the transaction and than the generator generate new one.
      
      trans = new(); //First transaction for the first byte in "frame"
      trans.rx_data = frame.header[7:0]; // first byte in frame
      gen2drv.put(trans);
      
      trans = new(); //Second transaction for the second byte in "frame"
      trans.rx_data = frame.header[15:8]; // second byte in frame
      gen2drv.put(trans);
      
      foreach (frame.payload[i]) begin // Payload 10 in header coorect otherwise random
        trans = new();
        trans.rx_data = frame.payload[i];
        gen2drv.put(trans);
      end
            
    end
    -> ended; //trigger end of generation
  endtask
  
endclass