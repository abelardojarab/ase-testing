// ***************************************************************************
// Copyright (c) 2013-2016, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Module Name:         arbiter.v
// Project:             NLB AFU 
// Description:
//
// ***************************************************************************
//
// ---------------------------------------------------------------------------------------------------------------------------------------------------
//                                         Arbiter
//  ------------------------------------------------------------------------------------------------------------------------------------------------
//
// This module instantiates different test AFUs, and connect them up to the arbiter.

`default_nettype none
module arbiter #(parameter PEND_THRESH=1, ADDR_LMT=20, MDATA=14, INSTANCE=32)
(

       // ---------------------------global signals-------------------------------------------------
       Clk_400               ,        // in    std_logic;  -- Core clock

       ab2re_WrAddr,                   // [ADDR_LMT-1:0]        app_cnt:           write address
       ab2re_WrTID,                    // [15:0]                app_cnt:           meta data
       ab2re_WrDin,                    // [511:0]               app_cnt:           Cache line data
       ab2re_WrFence,                  //                       app_cnt:           write fence
       ab2re_WrEn,                     //                       app_cnt:           write enable
       re2ab_WrSent,                   //                       app_cnt:           write issued
       re2ab_WrAlmFull,                //                       app_cnt:           write fifo almost full
       
       ab2re_RdAddr,                   // [ADDR_LMT-1:0]        app_cnt:           Reads may yield to writes
       ab2re_RdTID,                    // [15:0]                app_cnt:           meta data
       ab2re_RdEn,                     //                       app_cnt:           read enable
       re2ab_RdSent,                   //                       app_cnt:           read issued

       re2ab_RdRspValid,               //                       app_cnt:           read response valid
       re2ab_UMsgValid,                //                       arbiter:           UMsg valid
       re2ab_CfgValid,                 //                       arbiter:           Cfg valid
       re2ab_RdRsp,                    // [15:0]                app_cnt:           read response header
       re2ab_RdData,                   // [511:0]               app_cnt:           read data

       re2ab_WrRspValid,               //                       app_cnt:           write response valid
       re2ab_WrRsp,                    // [ADDR_LMT-1:0]        app_cnt:           write response header
       re2xy_go,                       //                       requestor:         start the test
       re2xy_src_addr,                 // [31:0]                requestor:         src address
       re2xy_dst_addr,                 // [31:0]                requestor:         destination address
       re2xy_NumLines,                 // [31:0]                requestor:         number of cache lines
       re2xy_stride,                   // [31:0]              requestor:      stride value
       re2xy_NumInst_sw,         // [31:0]                  requestor:           number of instances - SW test                                      
       re2xy_Numrepeat_sw,       // [31:0]             requestor:          number of times to run each instance of SW test before completion.
       re2xy_Cont,                     //                       requestor:         continuous mode
       re2xy_wrdin_msb,                //                     requestor:    modifies msb(1) of wrdata to differntiate b/n different multiple afu write patterns
        re2xy_test_cfg,                 // [7:0]                 requestor:         8-bit test cfg register.
       re2ab_Mode,                     // [2:0]                 requestor:         test mode
       ab2re_TestCmp,                  //                       arbiter:           Test completion flag
       ab2re_ErrorInfo,                // [255:0]               arbiter:           error information
       ab2re_ErrorValid,               //                       arbiter:           test has detected an error
       cr2s1_csr_write,
       test_Resetb,                    //                       requestor:         rest the app
     
       ab2re_RdLen,
       ab2re_RdSop,
       ab2re_WrLen,
       ab2re_WrSop,
          
       re2ab_RdRspFormat,
       re2ab_RdRspCLnum,
       re2ab_WrRspFormat,
       re2ab_WrRspCLnum,
       re2xy_multiCL_len                          // Default is 0 which implies single CL  
);
   
   input  logic                   Clk_400;               //                      ccip_intf:            Clk_400
   
   output logic  [ADDR_LMT-1:0]   ab2re_WrAddr;           // [ADDR_LMT-1:0]        app_cnt:           Writes are guaranteed to be accepted
   output logic  [15:0]           ab2re_WrTID;            // [15:0]                app_cnt:           meta data
   output logic  [511:0]          ab2re_WrDin;            // [511:0]               app_cnt:           Cache line data
   output logic                   ab2re_WrFence;          //                       app_cnt:           write fence.
   output logic                   ab2re_WrEn;             //                       app_cnt:           write enable
   input  logic                   re2ab_WrSent;           //                       app_cnt:           write issued
   input  logic                   re2ab_WrAlmFull;        //                       app_cnt:           write fifo almost full
   
   output logic  [ADDR_LMT-1:0]   ab2re_RdAddr;           // [ADDR_LMT-1:0]        app_cnt:           Reads may yield to writes
   output logic  [15:0]           ab2re_RdTID;            // [15:0]                app_cnt:           meta data
   output logic                   ab2re_RdEn;             //                       app_cnt:           read enable
   input  logic                   re2ab_RdSent;           //                       app_cnt:           read issued
   
   input  logic                   re2ab_RdRspValid;       //                       app_cnt:           read response valid
   input  logic                   re2ab_UMsgValid;        //                       arbiter:           UMsg valid
   input  logic                   re2ab_CfgValid;         //                       arbiter:           Cfg valid
   input  logic [15:0]            re2ab_RdRsp;            // [15:0]                app_cnt:           read response header
   input  logic [511:0]           re2ab_RdData;           // [511:0]               app_cnt:           read data
   
   input  logic                   re2ab_WrRspValid;       //                       app_cnt:           write response valid
   input  logic [15:0]            re2ab_WrRsp;            // [15:0]                app_cnt:           write response header
   
   input  logic                   re2xy_go;               //                       requestor:         start of frame recvd
   input  logic [31:0]            re2xy_src_addr;         // [31:0]                requestor:         src address
   input  logic [31:0]            re2xy_dst_addr;         // [31:0]                requestor:         destination address
   input  logic [31:0]            re2xy_NumLines;         // [31:0]                requestor:         number of cache lines
   input  logic [31:0]             re2xy_stride;          // [31:0]              requestor:      stride value
   input logic  [10:0]             re2xy_NumInst_sw;         // [31:0]                 requestor:           number of instances - SW test                               
   input logic  [20:0]            re2xy_Numrepeat_sw;       // [31:0]             requestor:          number of times to run each instance of SW test before completion.
   input  logic                   re2xy_Cont;             //                       requestor:         continuous mode
   input  logic [7:0]             re2xy_test_cfg;         // [7:0]                 requestor:         8-bit test cfg register.
   input  logic [2:0]             re2ab_Mode;             // [2:0]                 requestor:         test mode
   input  logic                re2xy_wrdin_msb;        //                       requestor:    modifies msb(1) of wrdata to differntiate b/n different multiple afu write patterns
   
   output logic                   ab2re_TestCmp;          //                       arbiter:           Test completion flag
   output logic  [255:0]          ab2re_ErrorInfo;        // [255:0]               arbiter:           error information
   output logic                   ab2re_ErrorValid;       //                       arbiter:           test has detected an error
   
   input  logic                   cr2s1_csr_write;
   input  logic                   test_Resetb;
   
   output logic  [1:0]            ab2re_RdLen;
   output logic                   ab2re_RdSop;
   output logic  [1:0]            ab2re_WrLen;
   output logic                   ab2re_WrSop;
        
   input  logic                   re2ab_RdRspFormat; // TODO: This is not applicable. Even Multi CL Rds return individual unpacked response always
   input  logic [1:0]             re2ab_RdRspCLnum;  // For unpacked rd rsp, OoO
   input  logic                   re2ab_WrRspFormat; // Packed or unpacked response for multi CL Writes.
   input  logic [1:0]             re2ab_WrRspCLnum;  // for unpacked wr rsp, could be OoO
   input  logic [1:0]             re2xy_multiCL_len; 
   
   //------------------------------------------------------------------------------------------------------------------------
   
  
  
   //------------------------------------------------------------------------------------------------------------------------
   //      test_sw1 signal declarations
   //------------------------------------------------------------------------------------------------------------------------
   
   wire [ADDR_LMT-1:0]     s12ab_WrAddr[0:INSTANCE-1];           // [ADDR_LMT-1:0]        app_cnt:           write address
   wire [15:0]             s12ab_WrTID[0:INSTANCE-1];            // [15:0]                app_cnt:           meta data
   wire [20:0]            s12ab_WrDin[0:INSTANCE-1];            // [511:0]               app_cnt:           Cache line data
   wire [INSTANCE-1:0]                   s12ab_WrEn;             //                       app_cnt:           write enable
   wire [INSTANCE-1:0]                   s12ab_WrFence;          //                       app_cnt:           write fence 
   reg                     ab2s1_WrSent[0:INSTANCE-1];           //                       app_cnt:           write issued
   reg                     ab2s1_WrAlmFull;        //                       app_cnt:           write fifo almost full
   
   wire [ADDR_LMT-1:0]     s12ab_RdAddr[0:INSTANCE-1];           // [ADDR_LMT-1:0]        app_cnt:           Reads may yield to writes
   wire [15:0]             s12ab_RdTID[0:INSTANCE-1];            // [15:0]                app_cnt:           meta data
   wire  [INSTANCE-1:0]                  s12ab_RdEn;             //                       app_cnt:           read enable
   reg                     ab2s1_RdSent[0:INSTANCE-1];           //                       app_cnt:           read issued
   
   reg                     ab2s1_RdRspValid[0:INSTANCE-1];       //                       app_cnt:           read response valid
   reg                     ab2s1_UMsgValid;        //                       app_cnt:           UMsg valid
   reg [15:0]              ab2s1_RdRsp[0:INSTANCE-1];            // [15:0]                app_cnt:           read response header
   reg [ADDR_LMT-1:0]      ab2s1_RdRspAddr[0:INSTANCE-1];        // [ADDR_LMT-1:0]        app_cnt:           read response address
   reg [511:0]             ab2s1_RdData[0:INSTANCE-1];           // [511:0]               app_cnt:           read data
   
   reg                     ab2s1_WrRspValid[0:INSTANCE-1];       //                       app_cnt:           write response valid
   reg [15:0]              ab2s1_WrRsp[0:INSTANCE-1];            // [15:0]                app_cnt:           write response header
   reg [ADDR_LMT-1:0]      ab2s1_WrRspAddr[0:INSTANCE-1];        // [Addr_LMT-1:0]        app_cnt:           write response address
   
   wire                    s12ab_TestCmp[0:INSTANCE-1];          //                       arbiter:           Test completion flag
   reg [10:0]              re2xy_NumInst_sw_reg;
   // local variables
   reg                     re2ab_RdRspValid_q, re2ab_RdRspValid_qq;
   reg                     re2ab_WrRspValid_q, re2ab_WrRspValid_qq;
   reg                     re2ab_UMsgValid_q, re2ab_UMsgValid_qq;
   reg                     re2ab_CfgValid_q, re2ab_CfgValid_qq; 
   reg [15:0]              re2ab_RdRsp_q, re2ab_RdRsp_qq;
   reg [15:0]              re2ab_WrRsp_q, re2ab_WrRsp_qq;
   reg [511:0]             re2ab_RdData_q, re2ab_RdData_qq;
   
   logic                   re2ab_RdRspFormat_q, re2ab_RdRspFormat_qq;
   logic [1:0]             re2ab_RdRspCLnum_q,  re2ab_RdRspCLnum_qq;
   logic                   re2ab_WrRspFormat_q, re2ab_WrRspFormat_qq;
   logic [1:0]             re2ab_WrRspCLnum_q, re2ab_WrRspCLnum_qq;
   
   reg [7:0] k;
   reg [7:0] i;
   reg                 re2xy_go_reg1;
   reg                  re2xy_go_reg2;
   reg                  sw_test_enable_reg[0:INSTANCE-1];
   reg                  sw_test_enable[0:INSTANCE-1]; 
   reg  [INSTANCE-1:0]     test_comp;
    wire                sw_test_comp; 
    logic [16:0] stride;
   assign stride = re2xy_stride[16:0];
   
   localparam NUM_INPUTS_READ       = INSTANCE;     
   localparam LOG2_NUM_READ      = $clog2(NUM_INPUTS_READ);
   localparam NUM_INPUTS_WRITE      = INSTANCE;    
   localparam LOG2_NUM_WRITE        = $clog2(NUM_INPUTS_WRITE);
   
   wire [LOG2_NUM_READ-1:0]  read_fair_arb_out;
   wire [LOG2_NUM_WRITE-1:0] write_fair_arb_out;
   wire                   write_out_valid;
   wire                   read_out_valid;
   reg [LOG2_NUM_READ-1:0]  read_fair_arb_out_q;
   reg [LOG2_NUM_WRITE-1:0] write_fair_arb_out_q;
   reg                      write_out_valid_q;
   reg                      read_out_valid_q;
   wire [INSTANCE-1:0]    read_in_valid;
   wire [INSTANCE-1:0]     write_in_valid;
   reg [INSTANCE-1:0]     read_in_valid_q;
   reg [INSTANCE-1:0]     write_in_valid_q;
   
   //------------------------------------------------------------------------------------------------------------------------
   // Arbitrataion Memory instantiation
   //------------------------------------------------------------------------------------------------------------------------
   wire [ADDR_LMT-1:0]     arbmem_rd_dout;
   wire [ADDR_LMT-1:0]     arbmem_wr_dout;
   
   nlb_gram_sdp #(.BUS_SIZE_ADDR(MDATA),
              .BUS_SIZE_DATA(ADDR_LMT),
              .GRAM_MODE(2'd3)
              )arb_rd_mem 
            (
                .clk  (Clk_400),
                .we   (ab2re_RdEn),        
                .waddr(ab2re_RdTID[MDATA-1:0]),     
                .din  (ab2re_RdAddr),       
                .raddr(re2ab_RdRsp[MDATA-1:0]),     
                .dout (arbmem_rd_dout )
            );     
   
   nlb_gram_sdp #(.BUS_SIZE_ADDR(MDATA),
              .BUS_SIZE_DATA(ADDR_LMT),
              .GRAM_MODE(2'd3)
             )arb_wr_mem 
            (
                .clk  (Clk_400),
                .we   (ab2re_WrEn),        
                .waddr(ab2re_WrTID[MDATA-1:0]),     
                .din  (ab2re_WrAddr),       
                .raddr(re2ab_WrRsp[MDATA-1:0]),     
                .dout (arbmem_wr_dout )
            );     
   
   //------------------------------------------------------------------------------------------------------------------------
   // Fair Arbiter instantiation
   //------------------------------------------------------------------------------------------------------------------------    
   assign read_in_valid  = {s12ab_RdEn[INSTANCE-1:0]};   
   assign write_in_valid = {s12ab_WrEn[INSTANCE-1:0]}; 
   
   mt_fair_arbiter #(.NUM_INPUTS(NUM_INPUTS_READ), 
         .LNUM_INPUTS(LOG2_NUM_READ)
      )
      read_fair_arbiter(
         Clk_400,
         test_Resetb,
         read_in_valid,
         read_fair_arb_out,
         read_out_valid
      );

   mt_fair_arbiter #(.NUM_INPUTS(NUM_INPUTS_WRITE), 
         .LNUM_INPUTS(LOG2_NUM_WRITE)
      )
      write_fair_arbiter(
         Clk_400,
         test_Resetb,
         write_in_valid,
         write_fair_arb_out,
         write_out_valid
      );
   //------------------------------------------------------------------------------------------------------------------------                                      
   
   //------------------------------------------------------------------------------------------------------------------------
   always @(posedge Clk_400)
     begin
        re2ab_RdData_q          <= re2ab_RdData;
        re2ab_RdRsp_q           <= re2ab_RdRsp;
        re2ab_WrRsp_q           <= re2ab_WrRsp;
        re2ab_RdData_qq         <= re2ab_RdData_q;
        re2ab_RdRsp_qq          <= re2ab_RdRsp_q;
        re2ab_WrRsp_qq          <= re2ab_WrRsp_q;
        if(~test_Resetb)
          begin
             re2ab_RdRspValid_q      <= 0;
             re2ab_UMsgValid_q       <= 0;
             re2ab_CfgValid_q        <= 0;
             re2ab_WrRspValid_q      <= 0;
             re2ab_RdRspValid_qq     <= 0;
             re2ab_UMsgValid_qq      <= 0;
             re2ab_CfgValid_qq       <= 0;
             re2ab_WrRspValid_qq     <= 0;
             re2ab_RdRspFormat_q     <= 0;
             re2ab_RdRspFormat_qq    <= 0;
             re2ab_RdRspCLnum_q      <= 0;
             re2ab_RdRspCLnum_qq     <= 0;
             re2ab_WrRspFormat_q     <= 0;
             re2ab_WrRspFormat_qq    <= 0;
             re2ab_WrRspCLnum_q      <= 0;
             re2ab_WrRspCLnum_qq     <= 0;
             
             re2xy_NumInst_sw_reg <= 0;
             re2xy_go_reg1      <= 1'b0;
             re2xy_go_reg2      <= 1'b0;
             read_fair_arb_out_q  <= 'b0; 
             write_fair_arb_out_q <= 'b0; 
             write_out_valid_q    <= 1'b0; 
             read_out_valid_q     <= 1'b0; 
             read_in_valid_q      <= 'b0  ;
             write_in_valid_q     <= 'b0  ;
             
             
             for (k=0; k<INSTANCE; k=k+1) 
         begin
         sw_test_enable_reg[k]<= 1'b0; 
         end
         
          end
        else
          begin
             re2ab_RdRspValid_q      <= re2ab_RdRspValid;
             re2ab_UMsgValid_q       <= re2ab_UMsgValid;
             re2ab_CfgValid_q        <= re2ab_CfgValid;
             re2ab_WrRspValid_q      <= re2ab_WrRspValid;
             re2ab_RdRspValid_qq     <= re2ab_RdRspValid_q;
             re2ab_UMsgValid_qq      <= re2ab_UMsgValid_q;
             re2ab_CfgValid_qq       <= re2ab_CfgValid_q;
             re2ab_WrRspValid_qq     <= re2ab_WrRspValid_q;
             re2ab_RdRspFormat_q     <= re2ab_RdRspFormat;
             re2ab_RdRspFormat_qq    <= re2ab_RdRspFormat_q;
             re2ab_RdRspCLnum_q      <= re2ab_RdRspCLnum;
             re2ab_RdRspCLnum_qq     <= re2ab_RdRspCLnum_q;
             re2ab_WrRspFormat_q     <= re2ab_WrRspFormat;
             re2ab_WrRspFormat_qq    <= re2ab_WrRspFormat_q;
             re2ab_WrRspCLnum_q      <= re2ab_WrRspCLnum;
             re2ab_WrRspCLnum_qq     <= re2ab_WrRspCLnum_q;
             
             re2xy_NumInst_sw_reg <= re2xy_NumInst_sw;
             re2xy_go_reg1         <= re2xy_go;
             re2xy_go_reg2       <= re2xy_go_reg1;
             read_fair_arb_out_q  <=  read_fair_arb_out; 
             write_fair_arb_out_q <=  write_fair_arb_out; 
             write_out_valid_q    <=  write_out_valid ; 
             read_out_valid_q     <=  read_out_valid  ; 
             read_in_valid_q      <= read_in_valid   ;
             write_in_valid_q     <= write_in_valid  ;
         
         for (k=0; k<INSTANCE; k=k+1)  
         begin
         sw_test_enable_reg[k]<= sw_test_enable[k]; 
         end
          end
     end
   
   always @(*)
     begin
        // OUTPUTs
        ab2re_WrAddr    = 0;
        ab2re_WrTID     = 0;
        ab2re_WrDin     = 'hx;
        ab2re_WrFence   = 0;
        ab2re_WrEn      = write_out_valid_q;
        ab2re_RdAddr    = 0;
        ab2re_RdTID     = 0;
        ab2re_RdEn      = read_out_valid_q;
        ab2re_TestCmp   = 0;
        ab2re_ErrorInfo = 'h0;
        ab2re_ErrorValid= 0;
    
        ab2re_RdLen     = 0;
        ab2re_RdSop     = 0;
        ab2re_WrLen     = 0;
        ab2re_WrSop     = 0; 
    
       
              ab2s1_WrAlmFull    = re2ab_WrAlmFull;
             ab2s1_UMsgValid    = re2ab_UMsgValid_qq;
        // ---------------------------------------------------------------------------------------------------------------------
        //      Input to tests        
        // ---------------------------------------------------------------------------------------------------------------------
   for (i=0; i<INSTANCE; i=i+1) 
         begin                 
               
               // Outputs from Arbiter to sw Tests : Responses
               ab2s1_WrSent[i]    = 0;
               ab2s1_RdSent[i]    = 0;
               ab2s1_RdRspValid[i]= 0;
               ab2s1_RdRsp[i]     = 0;
               ab2s1_RdRspAddr[i] = 0;
               ab2s1_RdData[i]    = 'hx;
               ab2s1_WrRspValid[i]= 0;
               ab2s1_WrRsp[i]     = 0;
               ab2s1_WrRspAddr[i] = 0;
               
                                       
               // Outputs from sw test to arbiter : Read Requests       
               if(read_fair_arb_out_q==i)   
               begin
                  ab2re_RdAddr       = s12ab_RdAddr[i] ;  
                  ab2re_RdTID          = s12ab_RdTID[i];
                  ab2s1_RdSent[i]    = re2ab_RdSent;
               end   
               
               // Write Requests             
               if(write_fair_arb_out_q==i)
               begin
                  ab2re_WrAddr       = s12ab_WrAddr[i] ;
                  ab2re_WrTID        = s12ab_WrTID[i];
                  ab2re_WrDin        = {491'b0 , s12ab_WrDin[i]};
                  ab2s1_WrSent[i]    = re2ab_WrSent;
               end
               
               // Read Responses to sw test 
               if(re2ab_RdRsp_qq[6:0]==i || ab2s1_UMsgValid)  //?? umsg
               begin
                  ab2s1_RdRspValid[i]   = re2ab_RdRspValid_qq;
                  ab2s1_RdRsp[i]        = re2ab_RdRsp_qq;
                  ab2s1_RdRspAddr[i]    = arbmem_rd_dout;
                  ab2s1_RdData[i]       = re2ab_RdData_qq;
               end   
               
               // Write Responses to sw test
               if(re2ab_WrRsp_qq[6:0]==i)
               begin
                  ab2s1_WrRspValid[i]   = re2ab_WrRspValid_qq;
                  ab2s1_WrRsp[i]        = re2ab_WrRsp_qq;
                  ab2s1_WrRspAddr[i]    = arbmem_wr_dout;
               end   
      end         
               
            
            
             // Output
//             ab2re_TestCmp      = sw_test_comp;
             ab2re_RdSop        = 1;
             ab2re_WrSop        = 1;
    
     end
//--------------------------------------------------------------------------------------------------------------
// Enable Instances of SW test
//--------------------------------------------------------------------------------------------------------------
     always@(*)
     begin
        for (i=0; i<INSTANCE; i=i+1) 
        begin
           if(re2xy_go_reg1 &&  ((i+1)<=re2xy_NumInst_sw_reg[7:0])) 
           begin
              sw_test_enable[i]  = 1'b1; 
           end
      
           else
           begin
              sw_test_enable[i] = 1'b0;
           end
        end
     end

//      // SW test completion
//   always@(*)
//   begin
//      for (i=0; i<INSTANCE; i=i+1) 
//      begin 
//         case ({sw_test_enable_reg[i],s12ab_TestCmp[i]})  /* synthesis parallel_case */
//            2'b10  : test_comp[i] = 1'b0;
//            2'b11  : test_comp[i] = 1'b1;
//            2'b01  : test_comp[i] = 1'b1;
//            2'b00  : test_comp[i] = 1'b1;
//         endcase  
//      end
//   end
//   assign sw_test_comp = re2xy_go_reg2 ? &test_comp : 0;
 
//--------------------------------------------------------------------------------------------------------------
// SW Test Instantiation 
//-------------------------------------------------------------------------------------------------------------- 
genvar j;
generate for (j=0; j<INSTANCE; j=j+1) 
   begin   
    test_sw1  #(.PEND_THRESH(PEND_THRESH),
                .ADDR_LMT   (ADDR_LMT),
                .MDATA      (MDATA),
                .INSTANCE   (j)
                )
    
    test_sw1 (
    
    //      ---------------------------global signals-------------------------------------------------
           Clk_400               ,        // in    std_logic;  -- Core clock
    
           s12ab_WrAddr[j],                   // [ADDR_LMT-1:0]        arb:               write address
           s12ab_WrTID[j],                    // [ADDR_LMT-1:0]        arb:               meta data
           s12ab_WrDin[j],                    // [511:0]               arb:               Cache line data
           s12ab_WrFence[j],                  //                       arb:               write fence 
           s12ab_WrEn[j],                     //                       arb:               write enable
           ab2s1_WrSent[j],                   //                       arb:               write issued
           ab2s1_WrAlmFull,                   //                       arb:               write fifo almost full
                                
           s12ab_RdAddr[j],                   // [ADDR_LMT-1:0]        arb:               Reads may yield to writes
           s12ab_RdTID[j],                    // [15:0]                arb:               meta data
           s12ab_RdEn[j],                     //                       arb:               read enable
           ab2s1_RdSent[j],                   //                       arb:               read issued
                                
           ab2s1_RdRspValid[j],               //                       arb:               read response valid
           ab2s1_UMsgValid,	                 //                       arb:               UMsg valid
           ab2s1_RdRsp[j],                    // [15:0]                arb:               read response header
           ab2s1_RdRspAddr[j],                // [ADDR_LMT-1:0]        arb:               read response address
           ab2s1_RdData[j],                   // [511:0]               arb:               read data
                                
           ab2s1_WrRspValid[j],               //                       arb:               write response valid
           ab2s1_WrRsp[j],                    // [15:0]                arb:               write response header
           ab2s1_WrRspAddr[j],                // [ADDR_LMT-1:0]        arb:               write response address
                                              
           sw_test_enable[j],                 //                       requestor:         start the test             
           re2xy_test_cfg,                    // [7:0]                 requestor:         8-bit test cfg register.            
           re2xy_Numrepeat_sw,	             // [31:0]				   requestor:		  No. of times to repeat the sw test.      
                                                                                                                     
           s12ab_TestCmp[j],                  //                       arb:               Test completion flag       
           test_Resetb,                              //                       requestor:         rest the app      
           (j<< stride)			               // input to sw [15:0]	   INSTANCE_ID*stride                                                                                           
        );  
      end 
endgenerate
endmodule

//--------------------------------------------------------------------------------------------------------------
// Fair Arbiter Module 
//-------------------------------------------------------------------------------------------------------------- 
module mt_fair_arbiter #(parameter NUM_INPUTS=2, LNUM_INPUTS=$clog2(NUM_INPUTS))
      (
      clk,
      reset_n,
      in_valid,
      out_select,
      out_valid
      );

   input  logic                 clk;
   input  logic                 reset_n;
   input  logic [NUM_INPUTS-1:0]    in_valid;
   output logic [LNUM_INPUTS-1:0]   out_select;
   output logic            out_valid;
   
   reg              out_valid;
   reg [LNUM_INPUTS-1:0] out_select;
   reg [LNUM_INPUTS-1:0] lsb_select, msb_select;
   reg [NUM_INPUTS-1:0]  lsb_mask;                       // bits [out_select-1:0]='0
   reg [NUM_INPUTS-1:0]  msb_mask;                       // bits [NUM_INPUTS-1:out_select]='0
   reg                   msb_in_notEmpty;
   integer i;
    
   always @(posedge clk)
   begin
      if(out_valid)
      begin
         msb_mask    <= ~({{NUM_INPUTS-1{1'b1}}, 1'b0}<<out_select); 
         lsb_mask    <=   {{NUM_INPUTS-1{1'b1}}, 1'b0}<<out_select;
      end

      if(!reset_n)
      begin
         msb_mask <= {NUM_INPUTS{1'b1}};
         lsb_mask <= {NUM_INPUTS{1'b0}};
      end
   end

   wire    [NUM_INPUTS-1:0]    msb_in = in_valid & lsb_mask;
   wire    [NUM_INPUTS-1:0]    lsb_in = in_valid & msb_mask;
    
   always@(*)
   begin
      msb_in_notEmpty = |msb_in;
      out_valid       = |in_valid;
      lsb_select = 0;
      msb_select = 0;

      for(i=NUM_INPUTS-1; i>=0; i=i-1)
      begin
         if(lsb_in[i])
            lsb_select = i;
         if(msb_in[i])
            msb_select = i;
      end
      out_select = msb_in_notEmpty ? msb_select : lsb_select;
   end
endmodule
