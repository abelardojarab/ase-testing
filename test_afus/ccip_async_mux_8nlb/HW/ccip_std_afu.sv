// ***************************************************************************
//
//        Copyright (C) 2008-2015 Intel Corporation All Rights Reserved.
//
// Engineer :           Pratik Marolia
// Creation Date :	20-05-2015
// Last Modified :	Wed 20 May 2015 03:03:09 PM PDT
// Module Name :	ccip_std_afu
// Project :        ccip afu top (work in progress)
// Description :    This module instantiates CCI-P compliant AFU

// ***************************************************************************
import ccip_if_pkg::*;
module ccip_std_afu(
  // CCI-P Clocks and Resets
  input           logic             pClk,              // 400MHz - CCI-P clock domain. Primary interface clock
  input           logic             pClkDiv2,          // 200MHz - CCI-P clock domain.
  input           logic             pClkDiv4,          // 100MHz - CCI-P clock domain.
  input           logic             uClk_usr,          // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
  input           logic             uClk_usrDiv2,      // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
  input           logic             pck_cp2af_softReset,      // CCI-P ACTIVE HIGH Soft Reset
  input           logic [1:0]       pck_cp2af_pwrState,       // CCI-P AFU Power State
  input           logic             pck_cp2af_error,          // CCI-P Protocol Error Detected

  // Interface structures
  input           t_if_ccip_Rx      pck_cp2af_sRx,        // CCI-P Rx Port
  output          t_if_ccip_Tx      pck_af2cp_sTx         // CCI-P Tx Port
);


//===============================================================================================
// User AFU goes here
//===============================================================================================

// NOTE: All inputs and outputs in PR region (AFU) must be registered
// NLB AFU registers all its outputs therefore not registered again here.
// Registering Inputs to AFU
//logic          pck_cp2af_softReset_T1;
t_if_ccip_Rx   pck_cp2af_sRx_T1;

localparam NUM_PORTS = 8;
localparam NUM_PIPE_STAGES = 2;

//----------------------------------------------------------------------------------------------
t_if_ccip_Rx pck_afu_RxPort [NUM_PORTS-1:0];
t_if_ccip_Tx pck_afu_TxPort [NUM_PORTS-1:0];
logic ccip_mux_reset_pass[NUM_PORTS-1:0];


//----------------------------------------------------------------------------------------------
/*
always@(posedge pClk)
begin
    pck_cp2af_sRx_T1           <= pck_cp2af_sRx;
    //pck_cp2af_softReset_T1     <= pck_cp2af_softReset;
end
*/
   logic 	  reset_pass;   
   logic 	  afu_clk;   
   logic      afu_clkDiv2;
   
   t_if_ccip_Tx nlb_tx;
   t_if_ccip_Rx nlb_rx;
   
   assign afu_clk = uClk_usr ;
   assign afu_clkDiv2 = uClk_usrDiv2;
   
   
   ccip_async_shim ccip_async_shim (
				    .bb_softreset    (pck_cp2af_softReset),
				    .bb_clk          (pClk),
				    .bb_tx           (pck_af2cp_sTx),
				    .bb_rx           (pck_cp2af_sRx),
				    .afu_softreset   (reset_pass),
				    .afu_clk         (afu_clk),
				    .afu_tx          (nlb_tx),
				    .afu_rx          (nlb_rx)
				    );

ccip_mux #(NUM_PORTS, NUM_PIPE_STAGES)
		ccip_mux_U0	(
			.pClk( afu_clk ),
			.pClkDiv2(afu_clkDiv2),
			.SoftReset( reset_pass ) ,        // upstream reset
			.up_Error(),
			.up_PwrState(),
			.up_RxPort( nlb_rx ),        // upstream Rx response port
			.up_TxPort( nlb_tx ),        // upstream Tx request port

			.afu_SoftReset(ccip_mux_reset_pass),
			.afu_PwrState(),
			.afu_Error(),
			.afu_RxPort(pck_afu_RxPort) ,   // downstream Rx response AFU
			.afu_TxPort(pck_afu_TxPort)     // downstream Tx request  AFU

		);

generate    
genvar n;
for(n=0;n<NUM_PORTS;n++)
begin: gen_nlb

	 nlb_lpbk nlb_lpbk(
		.Clk_400             ( afu_clk ) ,
		.SoftReset           ( ccip_mux_reset_pass[n] ) ,

		.cp2af_sRxPort       ( pck_afu_RxPort[n] ) ,
		.af2cp_sTxPort       ( pck_afu_TxPort[n] ) 
	);
/*

ccip_debug inst_ccip_debug(
  .pClk                (pClk),        
  .pck_cp2af_pwrState  (pck_cp2af_pwrState),
  .pck_cp2af_error     (pck_cp2af_error),



  .pck_cp2af_sRx       (pck_cp2af_sRx),   
  .pck_af2cp_sTx       (pck_af2cp_sTx)    
);
*/



    

end
endgenerate
endmodule
