class scoreboard;
   
  //create mailbox handle
  mailbox mon2scbin;
  mailbox mon2scbout;
  
     // Define the state machine states as an enumerated type
  typedef enum logic [1:0] {
    ref_IDLE,
    ref_LSB,
    ref_MSB,
    ref_DATA
  } frame_aligner_state_e;
  
  frame_aligner_state_e next_state = ref_IDLE;
  
  //count the number of transactions
  int num_transactions;
  // reference model registers

  int mon_in_scb;
  
  // Declare and initialize variables at the class level
  bit [1:0] fd_cnt = 2'b00;         // Legal Header Counter
  bit [3:0] ref_byte_position = 4'b0000;  // Byte position in frame
  bit [5:0] il_byte = 6'b000000;        // Illegal Bytes Counter
  bit ref_frame_detect = 1'b0;     // Reference Frame Detector
  bit [7:0] first_byte;  // First Byte Of Legal Header
  
  

  
  //constructor
  function new(mailbox mon2scbin, mailbox mon2scbout);
    //get the mailbox handle from  environment 
    this.mon2scbin = mon2scbin;
    this.mon2scbout = mon2scbout;
  endfunction
  
  //Compare the actual results with the expected results
  task main;
    transaction trans_in;
    transaction trans_out;
    forever begin
      mon_in_scb++;
      mon2scbin.get(trans_in);
      mon2scbout.get(trans_out);

      
      case(next_state)
    ref_IDLE:
      begin
	  fd_cnt = 2'b00;
	  //$display("Ilegal Bytes Result.\n\ ilegal_bytes: %0d",il_byte);
	  //$display("time is:%t",$time);
      //$display("next state.\n\ next state: %0s",next_state);	  
      ref_byte_position = 4'b0000;
	  if (il_byte == 6'b110000) begin
		 ref_frame_detect = 1'b0;
		 fd_cnt = 2'b00;
	  end
	  il_byte = il_byte + 1'b1;
		
        if(trans_in.rx_data == 8'hAA || trans_in.rx_data == 8'h55) begin //First byte of the legal header
          next_state = ref_LSB;
          first_byte = trans_in.rx_data;		
        end
        else begin
		//$display("Ilegal Bytes Result.\n\ ilegal_bytes: %0d",il_byte);
		next_state = ref_IDLE;

        end
      end
    ref_LSB:
      begin
	  //$display("next state.\n\ next state: %0s",next_state);
	    if (il_byte == 6'b110000) begin
          ref_byte_position = 0;
		  fd_cnt = 2'b00;
		  ref_frame_detect = 1'b0;
		  next_state = ref_IDLE;
        end
        if (trans_in.rx_data == 8'hAF && first_byte == 8'hAA || trans_in.rx_data == 8'hBA && first_byte == 8'h55) begin // Second byte of the header
          ref_byte_position = ref_byte_position +1'b1;
		  il_byte = 6'b000000;
          next_state = ref_MSB;          
          if (!ref_frame_detect) begin
            fd_cnt = fd_cnt + 1'b1;
          end
        end
		else begin
		il_byte = il_byte + 1'b1;
		next_state = ref_IDLE;		 
		end
      end
    ref_MSB:
	
      begin
	  if (fd_cnt == 2'b11) begin
		  ref_frame_detect = 1'b1;
          il_byte = 6'b000000;         
        end
		ref_byte_position = ref_byte_position +1'b1;
        next_state = ref_DATA; 
      end
    ref_DATA:
      begin
	  if (ref_frame_detect == 1'b0) begin
	  il_byte = il_byte + 1'b1;
	  end  
//$display("next state.\n\ next state: %0s",next_state);	  
        if (ref_byte_position == 8'd11) begin
          if (trans_in.rx_data == 8'hAA || trans_in.rx_data == 8'h55) begin
            next_state = ref_LSB;
            ref_byte_position = 4'b0000;
			first_byte = trans_in.rx_data;
          end else begin
            next_state = ref_IDLE;
            ref_byte_position = 4'b0000;
          end         
        end
        else begin
          ref_byte_position = ref_byte_position +1'b1;
          next_state = ref_DATA;
        end
      end //begin
        


endcase
      
      // Update the state
        //ref_state = next_state;
      if (il_byte == 6'd47) begin
        ref_frame_detect = 1'b0;
      end
          if (!(ref_byte_position == trans_out.fr_byte_position && ref_frame_detect == trans_out.frame_detect)) begin
    $display("~Wrong Result.\n\Reference: %0d Actual: %0d Reference_FD: %0d Actual_FD: %0d",ref_byte_position, trans_out.fr_byte_position, ref_frame_detect, trans_out.frame_detect);
	$display("time is:%t",$time);
	end
    /*else
      $display("~Wrong Result.\n\Reference: %0d Actual: %0d Reference_FD: %0d Actual_FD: %0d",ref_byte_position, trans_out.fr_byte_position, ref_frame_detect, trans_out.frame_detect);
     */
	 end
////////////////////////////////////////////////////////////////////////
        num_transactions++;
      trans_in.display_in("[ --Scoreboard_in-- ]");
      trans_out.display_out("[ --Scoreboard_out-- ]");

    //end //forever
  endtask
  
endclass