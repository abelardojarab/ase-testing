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
// Module Name:         test_sw1.v
// Project:             NLB AFU 
// Description:         hw + sw ping pong test. FPGA initializes a location X,
//                      flag the SW. The SW in turn copies the data to location
//                      Y and flag the FPGA. FPGA reads the data from location Y.
// ***************************************************************************
// ---------------------------------------------------------------------------------------------------------------------------------------------------
//                                         SW test 1
// ---------------------------------------------------------------------------------------------------------------------------------------------------
// Goal:
// Characterize 3 methods of notification from CPU to FPGA:
// 1. polling from AFU
// 2. UMsg without Data
// 3. UMsg with Data
// 3. CSR Write
//
// Test flow:
// 1. Wait on test_goErrorValid
// 2. Start timer. Write N cache lines. WrData= {16{32'h0000_0001}}
// 3. Write Fence.
// 4. FPGA -> CPU Message. Write to address N+1. WrData = {{14{32'h0000_0000}},{64{1'b1}}}
// 5. CPU -> FPGA Message. Configure one of the following methods:
//   a. Poll on Addr N+1. Expected Data [63:32]==32'hffff_ffff
//   b. CSR write to Address 0xB00. Data= Dont Care
//   c. UMsg Mode 0 (with data). UMsg ID = 0
//   d. UMsgH Mode 1 (without data). UMsg ID = 0
// 7. Read N cache lines. Wait for all read completions.
// 6. Stop timer Send test completion.
// 
// test mode selection:
// re2xy_test_cfg[7:6]  Description
// ----------------------------------------
// 2'h0                 Polling method
// 2'h1                 CSR Write
// 2'h2                 UMsg Mode 0 with data
// 2'h3                 UMsgH Mode 1, i.e. hint without data.
//
// Determine test overheads for latency measurements

`default_nettype none
module test_sw1 #(parameter PEND_THRESH=1, ADDR_LMT=20, MDATA=14, INSTANCE=32)
(
   //---------------------------global signals-------------------------------------------------
   Clk_400,                // input -- Core clock
        
   s12ab_WrAddr,            // output   [ADDR_LMT-1:0]    
   s12ab_WrTID,             // output   [ADDR_LMT-1:0]      
   s12ab_WrDin,             // output   [511:0]             
   s12ab_WrFence,           // output   write fence.
   s12ab_WrEn,              // output   write enable        
   ab2s1_WrSent,            // input                          
   ab2s1_WrAlmFull,         // input                          
  
   s12ab_RdAddr,            // output   [ADDR_LMT-1:0]
   s12ab_RdTID,             // output   [15:0]
   s12ab_RdEn,              // output 
   ab2s1_RdSent,            // input
   
   ab2s1_RdRspValid,        // input                    
   ab2s1_UMsgValid,         // input                    
   ab2s1_RdRsp,             // input    [15:0]          
   ab2s1_RdRspAddr,         // input    [ADDR_LMT-1:0]  
   ab2s1_RdData,            // input    [511:0]         
    
   ab2s1_WrRspValid,        // input                  
   ab2s1_WrRsp,             // input    [15:0]            
   ab2s1_WrRspAddr,         // input    [ADDR_LMT-1:0]    

   re2xy_go,                // input                 
   re2xy_test_cfg,          // input    [7:0]  
   re2xy_Numrepeat_sw,     // input [31:0]
    
   s12ab_TestCmp,           // output           
   test_Resetb,              // input   
   flag_Addr            // input [15:0]      = (2047*32) + INSTANCE
);

   input  logic                     Clk_400;               // csi_top:    Clk_400
   
   output logic   [ADDR_LMT-1:0]    s12ab_WrAddr;           // arb:        write address
   output logic   [15:0]            s12ab_WrTID;            // arb:        meta data
   output logic   [20:0]           s12ab_WrDin;            // arb:        Cache line data
   output logic                     s12ab_WrFence;          // arb:        write fence
   output logic                     s12ab_WrEn;             // arb:        write enable.
   input  logic                     ab2s1_WrSent;           // arb:        write issued
   input  logic                     ab2s1_WrAlmFull;        // arb:        write fifo almost full
   
   output logic   [ADDR_LMT-1:0]    s12ab_RdAddr;           // arb:        Reads may yield to writes
   output logic   [15:0]            s12ab_RdTID;            // arb:        meta data
   output logic                     s12ab_RdEn;             // arb:        read enable
   input  logic                     ab2s1_RdSent;           // arb:        read issued
   
   input  logic                     ab2s1_RdRspValid;       // arb:        read response valid
   input  logic                     ab2s1_UMsgValid;        // arb:        UMsg valid
   input  logic   [15:0]            ab2s1_RdRsp;            // arb:        read response header
   input  logic   [ADDR_LMT-1:0]    ab2s1_RdRspAddr;        // arb:        read response address
   input  logic   [511:0]           ab2s1_RdData;           // arb:        read data
   
   input  logic                     ab2s1_WrRspValid;       // arb:        write response valid
   input  logic   [15:0]            ab2s1_WrRsp;            // arb:        write response header
   input  logic   [ADDR_LMT-1:0]    ab2s1_WrRspAddr;        // arb:        write response address

   input  logic                     re2xy_go;               // requestor:  start of frame recvd
   input  logic   [7:0]             re2xy_test_cfg;         // requestor:  8-bit test cfg register.

   output logic                     s12ab_TestCmp;          // arb:        Test completion flag
   input  logic                     test_Resetb;
   input logic [15:0]           flag_Addr;           // input       (2047*32) + INSTANCE 
   input [20:0]           re2xy_Numrepeat_sw;     // requestor:  11 bits
   //------------------------------------------------------------------------------------------------------------------------
   // Rd FSM states
   localparam Vrdfsm_WAIT = 1'h0;
   localparam Vrdfsm_DONE = 1'h1;
   // Wr FSM states
   localparam Vwrfsm_WAIT = 2'h0;
   localparam Vwrfsm_UPDTFLAG = 2'h1;
   localparam Vwrfsm_DONE = 2'h2;

   // Rd Poll FSM
   localparam Vpollfsm_WAIT = 2'h0;
   localparam Vpollfsm_READ = 2'h1;
   localparam Vpollfsm_RESP = 2'h2;
   localparam Vpollfsm_DONE = 2'h3;


   reg                        s12ab_TestCmp_c1, s12ab_TestCmp_c2;        // arb:        Test completion flag
     
   reg      [1:0]             RdFSM;
   reg      [1:0]             PollFSM;

   reg      [2:0]             WrFSM;
   reg                        rd_go;
    reg      [21:0]          count_sw , fpga_sw;             // To track current Iteration 
  
   wire     [MDATA-4:0]       Wrmdata = s12ab_WrAddr[MDATA-4:0];
   wire     [MDATA-4:0]       Rdmdata = s12ab_RdAddr[MDATA-4:0];

   assign s12ab_RdTID = {(7'b000000 + INSTANCE) };        // Bits [13:8] = {1'b0, 5'bINSTANCE} 
   assign s12ab_WrTID = {(7'b000000 + INSTANCE)};          // INSTANCE ranges between [0 and 31]
         
   always @(*)
   begin
	
         s12ab_TestCmp_c1  = (RdFSM==Vrdfsm_DONE) && (count_sw[20:0] == re2xy_Numrepeat_sw [20:0]);   
         s12ab_RdEn       = (PollFSM == Vpollfsm_READ) && !ab2s1_RdSent ;
         s12ab_WrEn       = (WrFSM == Vwrfsm_UPDTFLAG) && !ab2s1_WrSent;
         s12ab_WrFence    = 1'b0;
   end

// Write FSM   
   always @(posedge Clk_400)
   begin
         s12ab_WrAddr   <= flag_Addr;
         s12ab_TestCmp  <= s12ab_TestCmp_c2;
         s12ab_TestCmp_c2  <= s12ab_TestCmp_c1;
         case(WrFSM)       /* synthesis parallel_case */
            Vwrfsm_WAIT:            // Wait for CPU to start the test
            begin
              
               if(re2xy_go)
               begin
                  
                       WrFSM   <= Vwrfsm_UPDTFLAG;
                   end
           end
            Vwrfsm_UPDTFLAG:        // FPGA -> CPU Message saying data is available
            begin
              if(ab2s1_WrSent)
              begin
                      WrFSM        <= Vwrfsm_DONE;
              end
            end
            
               Vwrfsm_DONE:
         begin
               if(RdFSM == Vrdfsm_DONE && (fpga_sw[20:0] < re2xy_Numrepeat_sw [20:0]))  
               begin
                  WrFSM       <= Vwrfsm_WAIT;
                   s12ab_WrDin    <= {fpga_sw[20:0]+1};
                   fpga_sw[20:0]  <= fpga_sw[20:0]+1;
               end
         end   
            
            default:
            begin
                WrFSM     <= WrFSM;
            end
         endcase
        
            if (!test_Resetb)
             begin
               WrFSM          <= Vwrfsm_WAIT;
               s12ab_TestCmp  <= 0;
                s12ab_WrDin  <= 1;
               fpga_sw     <= 1;
            end
       end

// Read FSM   
   always @(posedge Clk_400)
   begin
       
                        s12ab_RdAddr <= flag_Addr;
       case(re2xy_test_cfg[7:6])
           2'h0:            // polling method
           begin
               case(PollFSM)
                   Vpollfsm_WAIT:
                   begin
                        if(WrFSM==Vwrfsm_DONE && (ab2s1_WrRspAddr== flag_Addr) &&  ab2s1_WrRspValid)
                            PollFSM <= Vpollfsm_READ;
                   end
                   Vpollfsm_READ:
                   begin
                        if(ab2s1_RdSent)
                           PollFSM <= Vpollfsm_RESP;
                   end
                   Vpollfsm_RESP:
                   begin
                        if(ab2s1_RdRspValid)
                        begin
                              if(ab2s1_RdData[20:0]==(count_sw[20:0]+1'b1))
                            begin
                                rd_go <= 1;
                                PollFSM <= Vpollfsm_DONE;
                            end
                            else
                                PollFSM <= Vpollfsm_READ;
                        end
                   end
                   default: //Vpollfsm_DONE
                   begin
                       PollFSM <= PollFSM;
                   end
               endcase
           end
         
//           2'h2:            // UMsg Mode 0 (with Data)
//               rd_go    <= ab2s1_UMsgValid && ab2s1_RdRsp[15]==1'b0 && ab2s1_RdRsp[2:0]=='b0;
//           2'h3:            // UMsg Mode 1 (with Hint+Data)
//               rd_go    <= ab2s1_UMsgValid && ab2s1_RdRsp[15]==1'b1 && ab2s1_RdRsp[2:0]=='b0;
       endcase

       case(RdFSM)       /* synthesis parallel_case */
            Vrdfsm_WAIT:                            // Read Data payload
            begin
                if(rd_go)
                begin
                    count_sw <= count_sw + 1; 
                     RdFSM <= Vrdfsm_DONE;
                end
            end
 
            Vrdfsm_DONE:
         begin       
            if(count_sw[20:0] < (re2xy_Numrepeat_sw [20:0] -1))  
               begin
                  RdFSM       <= Vrdfsm_WAIT;
                  PollFSM     <= Vpollfsm_WAIT;
                  rd_go           <= 0;
                  
               end
         end
           
            default:
            begin
              RdFSM     <= RdFSM;
            end
       endcase         

        
      if (!test_Resetb)
       begin
          count_sw      <= 0;
             s12ab_RdAddr   <= 0;
         RdFSM          <= Vrdfsm_WAIT;          
         PollFSM        <= Vpollfsm_WAIT;
         rd_go          <= 0;
       end
      
   end
   
endmodule
