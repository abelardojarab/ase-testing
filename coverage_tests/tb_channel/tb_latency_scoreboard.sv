import ase_pkg::*;

module tb_latency_scoreboard();

   parameter TXN_COUNT = 8;
   parameter ADDR_BASE = 0;
         
   logic clk, rst, almfull, full, empty, valid_in, valid_out, read_en;     
   logic [DATA_WIDTH-1:0] data_in, data_out;
   
   TxHdr_t txhdr_in;
   TxHdr_t txhdr_out;
   RxHdr_t rxhdr_out;

   logic [CCIP_DATA_WIDTH-1:0] data0 = 512'hCAFECAFECAFECAFE_CAFECAFECAFECAFE_CAFECAFECAFECAFE_CAFECAFECAFECAFE_CAFECAFECAFECAFE_CAFECAFECAFECAFE_CAFECAFECAFECAFE_0000000000000000;
      
   int 			  ii;
   logic 		  overflow;
   
   // Buffer
   outoforder_wrf_channel
     #(
       .WRITE_CHANNEL (0)
       ) 
   buffer (clk, rst, txhdr_in, data_in, valid_in, txhdr_out, rxhdr_out, data_out, valid_out, read_en, empty, almfull, full, overflow );

   //clk
   initial begin
      clk = 0;      
      forever begin
	 #5;
	 clk = ~clk;	 
      end
   end

   logic start_reading;
   initial begin
      rst = 1;
      start_reading = 0;      
      #400;
      rst = 0;
      #600;
      start_reading = 0;      
   end

   int wr_iter;
   
   always @(posedge clk) begin
      if (rst) begin
	 valid_in <= 0;
	 wr_iter <= 0;
	 txhdr_in <= TxHdr_t'(0);
	 txhdr_in.vc <= VC_VA;
	 txhdr_in.sop <= 0;
	 txhdr_in.len <= ASE_1CL;
	 txhdr_in.addr <= ADDR_BASE;	
      end
      else begin
	 if ((~almfull) && (wr_iter < TNX_COUNT)) begin
	    $display(wr_iter);	    
	    wr_iter <= wr_iter + 1;
	    
	    valid_in <= 1;	    
	 end
	 else begin
	    valid_in <= 0;	    
	 end 
      end
   end

   assign read_en = ~empty;   

   
   // int checker_meta[*];
   
   initial begin
      #5000;
// `ifdef ASE_DEBUG
//      $display (buffer.checkunit.check_array);
// `endif
      $finish;     
   end

      
endmodule
