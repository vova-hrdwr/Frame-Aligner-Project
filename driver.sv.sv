//gets the packet from the generator and drives the transaction packet items into the interface 
//the interface is connected to the DUT, so that items driven into the interface will be driven 
//into the DUT

class driver;
  
  //count the number of transactions
  int num_transactions;
  
  //create virtual interface handle
  virtual inf vinf;
  
  //create mailbox handle
  mailbox gen2drv;
  
  //constructor
  function new(virtual inf vinf, mailbox gen2drv);
    //get the interface
    this.vinf = vinf;
    //get the mailbox handle from env 
    this.gen2drv = gen2drv;
  endfunction

  task reset;
    wait(vinf.rst);
    $display("[ --DRIVER-- ] ----- Reset Started -----");
    wait(!vinf.rst);
    $display("[ --DRIVER-- ] ----- Reset Ended   -----");
  endtask
  
  //drives the transaction items into interface signals
  task main;
    forever begin
      transaction trans;
      gen2drv.get(trans);
      @(negedge vinf.clk) 
        
      vinf.rx_data            <= trans.rx_data;

      //trans.display_in("[ --Driver-- ]");
      num_transactions++;
	  //$display("driver num of transactions is: %0d", num_transactions);
    end
  endtask
  
endclass