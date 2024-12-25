class frame_item;
    // Definitions
    typedef enum bit [1:0] {
        HEAD_1 = 2'b00, 
        HEAD_2 = 2'b01, 
        ILLEGAL = 2'b10
    } header_type_t;
    
    // Class members
    rand header_type_t header_type; // Header type (HEAD_1, HEAD_2, or ILLEGAL)
    logic [15:0]header;          // First two bytes as header
    rand byte payload[];            //Dynamic array Payload 


  function new();
    this.payload=new[0]; //Initialize dynamic array for the payload
  endfunction
    
    
    // Post-randomization function to set header values based on header type
    function void post_randomize();
        // Set header values based on header type
        case(header_type)
           HEAD_1:begin
                header = 16'hAFAA;
            end
            HEAD_2: begin
                header = 16'hBA55;
            end
          ILLEGAL: begin
                header = $urandom_range(16'h00, 16'hFF); // Generate a random byte for header
        end
        endcase
    endfunction
      
          // Constraints
      constraint header_constraint {
        // Randomly assign one of the header types with distribution
        header_type dist {HEAD_1 := 80 , HEAD_2 := 0, ILLEGAL := 20};
    }
    
      constraint payload_constraint {
        if (header_type == HEAD_1)  
          {payload.size == 10;}
        
        else if (header_type == HEAD_2) 
        {payload.size == 10;}
        
        else {
          payload.size inside {[0:46]};
        }
          foreach (payload[i]) payload[i] inside {[8'h00:8'hFF]};
      }
        
        
endclass
