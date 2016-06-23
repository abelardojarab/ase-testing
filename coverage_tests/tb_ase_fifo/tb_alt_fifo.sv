module tb_ase_fifo();

   parameter DATA_WIDTH = 64;
   parameter MAX_COUNT = 16;
   parameter DEPTH_BASE2 = 8;
   localparam FULL        = int'(2**DEPTH_BASE2 -1);
  // localparam ALMOST_FULL = int(3*FULL/4);
   //typedef logic [DATA_WIDTH-1:0]word_t; 
   
   logic clk, reset, full, empty, valid_in, valid_out, read_en,write_en;
   logic [DATA_WIDTH-1:0] data_in, data_out;
   logic [DEPTH_BASE2:0]  count;
   logic 		  start_reading;
   logic overflow,underflow,alm_full;
   logic [DATA_WIDTH-1:0]word_t; 
   logic [DATA_WIDTH-1:0]talt;
   int 			  wr_iter;
   int 			  rd_iter;
   logic [DATA_WIDTH-1:0]data;
   logic [DATA_WIDTH-1:0]k;
   task write(bit [DATA_WIDTH-1:0]talt);
     begin
	 @(posedge clk);
	   //$display("",$time,data);
	   data_in     <= talt;
	    write_en    <= 1'b1;
		read_en     <= 1'b0;
	    valid_in   <= $random %2;
	    //push_back(data);
       end
   endtask:write
   
   task reset_task(int num_rst_cycles);
    begin
         
	 repeat(num_rst_cycles)
	   begin
	      reset = 1'b1;
	      {read_en,write_en} = $random%2;
	      data_in = $random;
	      @(posedge clk);
	   end
	 reset =1'b0;
	 read_en = 1'b0;
	 write_en = 1'b0;
    end
    endtask  
	
   task idle_task(int num_idle_cycles);
     begin
	    @(posedge clk);
        read_en<=1'b0;
        write_en<=1'b0;
        data_in <='X;
       assert(num_idle_cycles < 10000) else
        $warning(" LARGE number of idle cycles	%0d ",num_idle_cycles);
       repeat(num_idle_cycles)@(posedge clk);
     end
   endtask: idle_task  
   
   	//Read and write tasks
   task read;
     begin
	   @(posedge clk);
	   data_in <= 'X;
       read_en <= 1;
        
     end
   endtask:read
   
    ase_svfifo
   #(DATA_WIDTH,DEPTH_BASE2,5)
   inst_fifo(
   .clk(clk),
   .rst(reset),
   .data_in(data_in),
   .rd_en(read_en),
   .wr_en(write_en),
   
   .data_out(data_out),
   .data_out_v(valid_out),
   .full(full),
   .empty(empty),
   .count(count),
   .overflow(overflow),
   .underflow(underflow)
   );

   //clk
   initial begin
      clk = 1;
      forever begin
	 #5;
	 clk = ~clk;
      end
   end

   
 initial 
      begin
       
         reset_task(5);		
		 //PUSH 6 values
		 #10;
	    for(int j=0;j<=512; j++) begin
		   k = $random;
		    write(k);	
           $display("write is ",k);		   
	       idle_task(5);
		    //write(11);
	    end	 
		
		//POP 6 values
	   for(int j=0;j<=259 ; j++) begin
		 read;
	    idle_task(5);
	    end
		
		
		//Random pop and Push
	    for(int i=0;i<=10;i++)begin
		
		
	    if($random%2)begin
		   k = $random;
	       write(k);
	       idle_task(5);
	    end
	    else begin
	       read;
	       idle_task(5);
	     end
	    end
		#10;
		
     $finish;
    end
	
//	always@(data_in or data_out or reset or read_en or write_en)
    initial $monitor($time," Reset = %d , Data_in = %h, Data_out = %h , write_en = %d , Read_en = %d  alm_full = %d ,full = %d, empty = %d,count = %h,overflow = %d, underflow = %d \n",reset,data_in,data_out,write_en,read_en,alm_full,full, empty ,count,overflow, underflow); 

 endmodule
