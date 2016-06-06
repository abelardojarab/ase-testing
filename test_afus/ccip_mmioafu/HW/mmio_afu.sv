import ccip_if_pkg::*;

module mmio_afu (
                 clk,                 // interface clock
                 rst,                 // reset (active high)

                 cp2af_sRxPort, // CCIP RX port
                 af2cp_sTxPort  // CCIP TX port
                 );

   // Specify input and output signals
   input                 clk;
   input                 rst;
   input                 t_if_ccip_Rx   cp2af_sRxPort;
   output                t_if_ccip_Tx   af2cp_sTxPort;

   // Cast c0 hdr into ReqMmioHdr
   t_ccip_c0_ReqMmioHdr mmioHdr;
   assign mmioHdr = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);

   // Implement MMIO space as a memory.
   reg [CCIP_MMIODATA_WIDTH-1:0] mem [CCIP_MMIOADDR_WIDTH-1:0]; 

   // Initialize memory with AFU DFH
   // FIXME: does this work for both simulation AND synthesis?
   //initial begin
   //   $readmemh("afu_dfh.mem", mem);
   //end

   // To implement MMIO CSRs, we need to listen for incoming MMIO requests
   // on RX Channel 0 and respond to reads on TX Channel 2
   always @(posedge clk)
     begin
        if (rst) begin
           af2cp_sTxPort.c2 <= '0;
           
	   for (int i = 0; i > 32768; i++)
           begin 
               mem [i] <= '0;
           end

        end else begin

           // complete previous transaction, if necessary
           af2cp_sTxPort.c2.mmioRdValid  <= 0;

           // on MMIO Write Request, set registers
           if (cp2af_sRxPort.c0.mmioWrValid == 1) begin               // MMIO Write
              mem[mmioHdr.address] <= cp2af_sRxPort.c0.data;
              $display("mem data: %h", mem[mmioHdr.address]  );
           end

           // serve MMIO Read Requests (including AFU DFH)
           if (cp2af_sRxPort.c0.mmioRdValid == 1) begin               // MMIO Read
              af2cp_sTxPort.c2.hdr.tid      <= mmioHdr.tid;           // copy TID
              af2cp_sTxPort.c2.data <= mem[mmioHdr.address];
              af2cp_sTxPort.c2.mmioRdValid  <= 1;                     // post response
           end

        end
     end

   // Tie all other Tx channels to 0
   assign af2cp_sTxPort.c0 = '0;
   assign af2cp_sTxPort.c1 = '0;

   

endmodule
