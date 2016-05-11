// ***************************************************************************
//
//        Copyright (C) 2008-2013 Intel Corporation All Rights Reserved.
//
// Engineer:            Narayanan Ravichandran
// Create Date:         Sat Feb 20 13:51:17 PDT 2016
// Module Name:         test_atomic.v
// Project:             NLB AFU 
// Description:         See Spec and Test flow below
//
// ***************************************************************************

/*
//=========================================================================================================== 
// COMPARE AND EXCHANGE - CCI-P SPEC 
//===========================================================================================================
CMP_DATA    - old data in CL  (64b). Depends on test sub-mode
NEW_DATA    - new data to be swapped  (64b). Depends on test submode
Qword       - Offset of Qword within CL. There are 8 possible locations, so [2:0]. Controlled by test config
CL_Addr     - Address of CL for CX operation. 

REQUEST
=======
TxData      - { 192'h0, 64'hCMP_DATA, 192'h0, 64'hNEW_DATA}            
TxHdr       - { QWord, Rsvd, VCsel, sop,  Rsvd, Req_type, Rsvd, Address,                      MDATA     }
TxHdr       - { 3'h0,  3'h0, 2'h1,  1'h1, 3'h0, 4'h5,     6'h0, {22'hBaseAddr,20'hCL_Addr},   16'hMDATA }
       
RESPONSE
========     
RxData      - { 512'hOLD_DATA }              
RxHdr       - { VCused, Rsvd, CacheHit, Rsvd, Success, RspType, MDATA        }
RxHdr       - { 2'h1,   1'hx, 1'hx,     3'hx, 1'h1/0,  4'h5,    16'hRspMDATA }
*/

/*
//=========================================================================================================== 
// COMPARE AND EXCHANGE (CX) - TEST FLOW
//===========================================================================================================
Test performs atomic cmp&cxhg operation through virtual channel vl0. 
Each instance/ thread of the test in HW has a corresponding counterpart in SW.
A given instance of HW always operates on the same CL.
When a single thread is used, there is only one outstanding CX and response ordering is guaranteed 
When multiple threads issue CX in parallel, MDATA is used to decode CX response which can be received OoO

cmp&xchg test has 2 sub-modes which is configurable at runtime through MMIO write
ab2at_submode = 0 ==> separate token (Default mode is separate token)
ab2at_submode = 1 ==> shared   token 

Other configurable runtime parameters are: 
ab2at_qword - Qword offset within a CL (Valid Range is 0 to 7)
ab2at_numCX - Number of CX operations to be performed by HW thread for test completion (Valid Range is 2 to 65534)

separate token
==============
- The Qword is initialized to 0 by SW before starting the test.
- Initially  <compare_data> = 0; <new_data> = 1, i.e. HW begins by comparing 0 and writing 1 to the QWord.
- HW thread performs 'ab2at_numCX' CXs on 'ab2at_qword' incrementing <compare_data> and <new_data> by 1 for each CX operation. 
- If CX operation response is received with CX status=fail, the HW thread will retry the CX with same set of data.
- Maximum number of retries permitted for each CX operation = 1024 
- From HW point of view, test completes when HW receives CX response=success for 'ab2at_numCX'th operation.
- SW thread does the same sequence of operations on its own QWord in the same CL using x86 CX. SW, HW threads operate on different QWords.
- Overall test completes when both SW, HW report test completion 

shared token
============
- SW and HW threads operate on same QWord in the same CL, hence the name shared token.
- The Qword is initialized to 0 by SW before starting the test.
- Upon receiving test_go, HW thread begins by comparing 0 and writing 1 to the QWord.
- SW in the mean time starts performing x86 CX by comparing 1 and writing 2 to the QWord.
- SW,HW threads operate in a lock-stepped style on same QWord with SW always comparing odd val, writing even val and HW, vice versa.
- Test completes when Num_SW_CX + Num_HW_CX = 'ab2at_numCX'
- If ab2at_numCX is even, SW and HW perform equal CXs with HW doing the first CX and SW doing the last CX.
- If ab2at_numCX is odd, HW performs one extra CX. In other words, HW does both the first and last CX.
*/
module test_atomic #(parameter PEND_THRESH=1, ADDR_LMT=20, MDATA=14)
(
   // Global signals
   input    logic                  Clk_16UI,                // input -- Core clock
      
   // Test Config 
   input    logic                  test_Resetb,             // input            
   input    logic                  re2xy_go,                // input                 
   input    logic                  ab2at_submode,
   input    logic [2:0]            ab2at_qword,
   input    logic [15:0]           ab2at_numCX,
   
   // C0 Req -- Unused 
   output   logic [ADDR_LMT-1:0]   at2ab_RdAddr,            // output   [ADDR_LMT-1:0]
   output   logic [15:0]           at2ab_RdTID,             // output   [15:0]
   output   logic                  at2ab_RdEn,              // output 
  
   // C0 Backpressure -- Unused
   input    logic                  ab2at_RdSent,            // input
   
   // C0 Response
   input    logic                  ab2at_RdRspValid,        // input                    
   input    logic [15:0]           ab2at_RdRsp,             // input    [15:0]          
   input    logic [ADDR_LMT-1:0]   ab2at_RdRspAddr,         // input    [ADDR_LMT-1:0]  
   input    logic [511:0]          ab2at_RdData,            // input    [511:0]         
   input    logic                  ab2at_cxSuccess,         // input             
   
   //  C1 Req 
   output   logic [ADDR_LMT-1:0]   at2ab_WrAddr,            // output   [ADDR_LMT-1:0]    
   output   logic [15:0]           at2ab_WrTID,             // output   [ADDR_LMT-1:0]      
   output   logic [511:0]          at2ab_WrDin,             // output   [511:0]             
   output   logic                  at2ab_cxReq,
   output   logic [2:0]            at2ab_cxQword,
   
   // C1 Back pressure 
   input    logic                  ab2at_WrSent,            // input                          
   input    logic                  ab2at_WrAlmFull,         // input                          
   
   // C1 Response -- Unused
   input    logic                  ab2at_WrRspValid,        // input                  
   input    logic [15:0]           ab2at_WrRsp,             // input    [15:0]            
   input    logic [ADDR_LMT-1:0]   ab2at_WrRspAddr,         // input    [ADDR_LMT-1:0]    
      
   // Test completion
   output   logic                  at2ab_TestCmp,           // output           
   output   logic [255:0]          at2ab_ErrorInfo,         // output   [255:0] 
   output   logic                  at2ab_ErrorValid         // output   
);

//======================================================================================== 
// Parameters
//========================================================================================
localparam  atFSM_WAIT  = 2'h0;
localparam  atFSM_REQ   = 2'h1;
localparam  atFSM_RSP   = 2'h2;
localparam  atFSM_DONE  = 2'h3;

//======================================================================================== 
// Counters and locals
//========================================================================================
(* noprune *) logic     [15:0]     cmpDin;
(* noprune *) logic     [15:0]     newDin;
(* noprune *) logic     [1:0]      atFSM;
(* noprune *) logic     [31:0]     Num_CxReqs;      
(* noprune *) logic     [15:0]     Num_CxRetry;      
(* noprune *) logic     [15:0]     Num_CxRsp;
(* noprune *) logic     [15:0]     cmplt_count;
(* noprune *) logic                ErrorValid;
(* noprune *) logic                Err_timeout;
(* noprune *) logic     [255:0]    at2ab_ErrorInfo_T0;
(* noprune *) logic                at2ab_ErrorValid_T0;
(* noprune *) logic                at2ab_TestCmp_c;

//======================================================================================== 
// Outputs from Test
//========================================================================================
always_comb
begin
  at2ab_WrAddr          = 0;
  at2ab_WrTID           = at2ab_WrAddr[15:0]; // CL ID
  at2ab_WrDin           = {240'h0,newDin[15:0],240'h0,cmpDin[15:0]};
  at2ab_cxReq           = (atFSM == atFSM_REQ);
  at2ab_cxQword         = ab2at_qword;               
  ErrorValid            = test_Resetb && Err_timeout;                     
  at2ab_TestCmp_c       = (atFSM == atFSM_DONE);
end

//======================================================================================== 
// Atomic Compare & Exchange Controller
//========================================================================================
always @(posedge Clk_16UI)
begin
  at2ab_TestCmp         <= at2ab_TestCmp_c;
  cmpDin                <= cmpDin;
  newDin                <= newDin;
  cmplt_count           <= ab2at_numCX - 1'b1;
  Num_CxRetry           <= Num_CxRetry;
  
  case(atFSM)             /* synthesis parallel_case */
    atFSM_WAIT:                                        
    begin
      if(re2xy_go)                                     // Wait for CPU to start the test
      begin
        atFSM           <= atFSM_REQ;
        newDin          <= {15'h0, 1'h1};
        cmpDin          <= {15'h0, 1'h0};
      end
    end
    
    atFSM_REQ:                                         // Send cmp_xchng request
    begin
      if(ab2at_WrSent)
      begin
        Num_CxReqs      <= Num_CxReqs + 1'b1;
        atFSM           <= atFSM_RSP;
      end
    end
    
    atFSM_RSP:                                         // Wait for cmp_xchng response
    begin    
      if(ab2at_RdRspValid && ab2at_RdRsp[2:0]==3'h0 && ab2at_cxSuccess)
      begin
        Num_CxRsp       <= Num_CxRsp + 1'b1;
        if(Num_CxRsp == cmplt_count)                   // Test Completion
        begin
          atFSM         <= atFSM_DONE;
        end
    
        else                                           // Send new CX command
        begin                                          
          atFSM         <= atFSM_REQ;
          newDin        <= newDin + 1'b1 + ab2at_submode;
          cmpDin        <= cmpDin + 1'b1 + ab2at_submode;
          Num_CxRetry   <= 0;
        end
      end
     
      else if (ab2at_RdRspValid && ab2at_RdRsp[2:0]==3'h0)
      begin                                            // Retry CX
        atFSM           <= atFSM_REQ;
        Num_CxRsp       <= Num_CxRsp;
        Num_CxRetry     <= Num_CxRetry + 1'b1;
      end
    end

    default:                                           // Default  
    begin
      atFSM             <= atFSM;
    end
  endcase
  
  if (Num_CxRetry[9])                                  // TODO: Test reports an error if 1024 consecutive CXs fail
  begin
    Err_timeout         <= 1'b1;
  end
  
  if(ErrorValid) 
  begin
    at2ab_ErrorValid_T0 <= 1'b1;
    at2ab_ErrorValid    <= at2ab_ErrorValid_T0;
    at2ab_ErrorInfo_T0  <= {newDin,cmpDin,Num_CxRetry,Num_CxReqs,Num_CxRsp};
    at2ab_ErrorInfo     <= at2ab_ErrorInfo_T0;
  end
  
  if (!test_Resetb)
  begin
    cmpDin              <= 0;
    newDin              <= 0;
    Num_CxReqs          <= 0;
    Num_CxRsp           <= 0;
    Num_CxRetry         <= 0;
    atFSM               <= atFSM_WAIT;
    at2ab_TestCmp       <= 0;
    at2ab_RdEn          <= 0;
    cmplt_count         <= 0;
    Err_timeout         <= 0;
    at2ab_ErrorValid    <= 0;
    at2ab_ErrorValid_T0 <= 0;
    at2ab_ErrorInfo_T0  <= 0;
    at2ab_ErrorInfo     <= 0;
  end
end   
endmodule
