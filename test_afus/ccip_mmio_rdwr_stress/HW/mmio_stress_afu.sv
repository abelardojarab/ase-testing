import ccip_if_pkg::*;

module mmio_stress_afu
  (
   // CCI-P Clocks and Resets
   input logic 	     pClk,
   input logic 	     pClkDiv2,
   input logic 	     pClkDiv4,
   input logic 	     uClk_usr,
   input logic 	     uClk_usrDiv2,
   input logic 	     pck_cp2af_softReset,
   input logic [1:0] pck_cp2af_pwrState,
   input logic 	     pck_cp2af_error,
   input 	     t_if_ccip_Rx pck_cp2af_sRx,
   output 	     t_if_ccip_Tx pck_af2cp_sTx
   );

   parameter int     CCIP_MMIO_BYTEWIDTH = CCIP_MMIOADDR_WIDTH + 2;
      
   logic [7:0] 	     regs [0:2**CCIP_MMIO_BYTEWIDTH-1];
   // logic [7:0] 	     regs [0:CCIP_MMIO_BYTEWIDTH-1];


`define AFUID_LO   64'h96bf6f5fc4038fac
`define AFUID_HI   64'h10c1bff188d14dfb

   t_ccip_c0_ReqMmioHdr CfgHdr;
   logic [CCIP_MMIO_BYTEWIDTH-1:0] cfg_mmioaddr;
   
   assign CfgHdr = t_ccip_c0_ReqMmioHdr'(pck_cp2af_sRx.c0.hdr);
   assign cfg_mmioaddr = {CfgHdr.address, 2'b0};
   
   
   // MMIO Write
   always @(posedge pClk) begin
      if (pck_cp2af_sRx.c0.mmioWrValid && (CfgHdr.length == 2'b00)) begin	 
	 regs [cfg_mmioaddr + 0] <= pck_cp2af_sRx.c0.data[ 7:0];
	 regs [cfg_mmioaddr + 1] <= pck_cp2af_sRx.c0.data[15:8];
	 regs [cfg_mmioaddr + 2] <= pck_cp2af_sRx.c0.data[23:16];
	 regs [cfg_mmioaddr + 3] <= pck_cp2af_sRx.c0.data[31:24];	 
      end
      else if (pck_cp2af_sRx.c0.mmioWrValid && (CfgHdr.length == 2'b01)) begin
	 regs [cfg_mmioaddr + 0] <= pck_cp2af_sRx.c0.data[ 7:0 ];
	 regs [cfg_mmioaddr + 1] <= pck_cp2af_sRx.c0.data[15:8 ];
	 regs [cfg_mmioaddr + 2] <= pck_cp2af_sRx.c0.data[23:16];
	 regs [cfg_mmioaddr + 3] <= pck_cp2af_sRx.c0.data[31:24];
	 regs [cfg_mmioaddr + 4] <= pck_cp2af_sRx.c0.data[39:32];
	 regs [cfg_mmioaddr + 5] <= pck_cp2af_sRx.c0.data[47:40];
	 regs [cfg_mmioaddr + 6] <= pck_cp2af_sRx.c0.data[55:48];
	 regs [cfg_mmioaddr + 7] <= pck_cp2af_sRx.c0.data[63:56];
      end
   end

   // MMIO Read
   always @(posedge pClk) begin
      if (pck_cp2af_softReset) begin
	 {regs[7],regs[6],regs[5],regs[4],regs[3],regs[2],regs[1],regs[0]}       <= 64'h1000000000001071;
	 {regs[15],regs[14],regs[13],regs[12],regs[11],regs[10],regs[9],regs[8]} <= `AFUID_LO;
	 {regs[23],regs[22],regs[21],regs[20],regs[19],regs[18],regs[17],regs[16]} <= `AFUID_HI;	 
      end
      else begin
	 if (pck_cp2af_sRx.c0.mmioRdValid && (CfgHdr.length == 2'b00)) begin
	    pck_af2cp_sTx.c2.data        <= {32'b0, regs [cfg_mmioaddr + 3], regs [cfg_mmioaddr + 2], regs [cfg_mmioaddr + 1], regs [cfg_mmioaddr + 0]};	    
	    pck_af2cp_sTx.c2.hdr.tid     <= CfgHdr.tid;
	    pck_af2cp_sTx.c2.mmioRdValid <= 1;
	 end
	 else if (pck_cp2af_sRx.c0.mmioRdValid && (CfgHdr.length == 2'b01)) begin
	    pck_af2cp_sTx.c2.data        <= {regs [cfg_mmioaddr+7], regs [cfg_mmioaddr+6], regs [cfg_mmioaddr+5], regs [cfg_mmioaddr+4], regs [cfg_mmioaddr+3], regs [cfg_mmioaddr+2], regs [cfg_mmioaddr+1], regs [cfg_mmioaddr+0]};
	    pck_af2cp_sTx.c2.hdr.tid     <= CfgHdr.tid;
	    pck_af2cp_sTx.c2.mmioRdValid <= 1;
	 end
	 else begin
	    pck_af2cp_sTx.c2.mmioRdValid <= 0;
	 end
      end
   end

   // TX channel 0 out
   assign pck_af2cp_sTx.c0 = 0;
   assign pck_af2cp_sTx.c1 = 0;
      
   
endmodule // mmio_stress_afu

