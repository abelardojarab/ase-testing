`include "svunit_defines.svh"

module ccip_checker_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "ccip_checker";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  // Configure enable
	logic 			  finish_logger,init_sniffer,ase_reset;
    // -------------------------------------------------------- //
    //      Channel overflow/realfull checks
    logic 			  cf2as_ch0_realfull,cf2as_ch1_realfull;
    // -------------------------------------------------------- //
    //          Hazard/Indicator Signals                        //
    ase_haz_if haz_if;  
    logic [SNIFF_VECTOR_WIDTH-1:0] error_code;
    // -------------------------------------------------------- //
    //              CCI-P interface                             //
    logic 			  clk=0;
    logic 			  SoftReset;
	t_if_ccip_Rx ccip_rx;
	t_if_ccip_Tx ccip_tx;
 
	ccip_checker
	#(
    .ERR_LOGNAME("ccip_warning_and_errors.txt")
    )  ccip_checker_ut
	(.* );
	

	
  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

  // ccip_sniffer_ut = new();
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask
  always #5 clk=~clk; 
  //===================================
  //------- CLOCKED BLOCK ------------
  //===================================
	default clocking clk_cb @(posedge clk);
		output   finish_logger,init_sniffer,ase_reset,cf2as_ch0_realfull,cf2as_ch1_realfull;
		output   haz_if,clk,SoftReset,ccip_rx,ccip_tx;
		input    error_code;
	endclocking

  // --------- CLOCK Instantiation ---//
	

  //===================================
  // ---------- TASKS -----------------
  //===================================
  task checker_running();
		##0;
		clk_cb.init_sniffer<=1'b0;
		##1;
		clk_cb.init_sniffer<=1'b1;
		##2;
		clk_cb.init_sniffer<=1'b0;
  endtask
  
  task reset();
		clk_cb.ase_reset <=1;
		clk_cb.SoftReset <=1;
		##2;
		clk_cb.SoftReset <=0;
		clk_cb.ase_reset <=0;
  endtask
  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN
	`SVTEST(CHECKER_INITIALIZED)
			fork			
			checker_running();				
			
				begin	
				##3;
				`FAIL_UNLESS_EQUAL(clk_cb.error_code[0],0);
				end
			
			join
     `SVTEST_END	
	 
	  `SVTEST(ASE_Reset)
			clk_cb.ase_reset <=1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[1],0);	 
	 `SVTEST_END
	 
	 `SVTEST(SoftReset)
			clk_cb.SoftReset <=1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code,0);	
            ##1;
			clk_cb.SoftReset <=0;
			clk_cb.ase_reset <=0;
	 `SVTEST_END
	 
	 `SVTEST(C0TX_INVALID_REQTYPE)
			reset();
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr.req_type <= eREQ_RDLINE_S;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[5],0);	
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[10],1);
			##1;
			
			clk_cb.ccip_tx.c0.valid <= 0;
		    reset();
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr.req_type <= eREQ_RDLINE_I;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[5],0);	
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[10],1);
			##1;
			
			clk_cb.ccip_tx.c0.valid <= 0;
			reset();
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr.req_type <= 3;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[5],1);			
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[10],1);
			##1;
			
	 `SVTEST_END
	 
	 `SVTEST(C0TX_OVERFLOW )
			reset();			
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.cf2as_ch0_realfull <= 1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[6],1);	
			##1;
			
			reset();			
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.cf2as_ch0_realfull <= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[6],0);	
			##1;			
	
	 `SVTEST_END
	 
	 `SVTEST(C0TX_ADDRALIGN_2)
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= eREQ_RDLINE_S;
			clk_cb.ccip_tx.c0.hdr.cl_len <= 2'b01;
			clk_cb.ccip_tx.c0.hdr.address <=2;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[7],0);	
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[8],0);	
			##1;
			clk_cb.ccip_tx.c0.valid <= 0;
			
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= eREQ_RDLINE_I;
			clk_cb.ccip_tx.c0.hdr.cl_len <= 2'b01;
			clk_cb.ccip_tx.c0.hdr.address <= 2;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[7],0);	
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[8],0);	
			##1;
			clk_cb.ccip_tx.c0.valid <= 0;
			
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= eREQ_RDLINE_I;
			clk_cb.ccip_tx.c0.hdr.cl_len <= 2'b01;
			clk_cb.ccip_tx.c0.hdr.address <=1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[7],1);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[13],1);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[8],0);				
			
	 `SVTEST_END
	 
	 `SVTEST(C0TX_ADDRALIGN_4)
			clk_cb.ccip_tx.c0.valid <= 0;
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= eREQ_RDLINE_S;
			clk_cb.ccip_tx.c0.hdr.cl_len <= 2'b11;
			clk_cb.ccip_tx.c0.hdr.address <=4;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[7],0);	
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[8],0);	
			##1;
			clk_cb.ccip_tx.c0.valid <= 0;
			
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= eREQ_RDLINE_I;
			clk_cb.ccip_tx.c0.hdr.cl_len <= 2'b11;
			clk_cb.ccip_tx.c0.hdr.address <= 4;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[7],0);	
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[8],0);	
			##1;
			clk_cb.ccip_tx.c0.valid <= 0;
			
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= eREQ_RDLINE_I;
			clk_cb.ccip_tx.c0.hdr.cl_len <= 2'b11;
			clk_cb.ccip_tx.c0.hdr.address <= 3;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[8],1);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[13],1);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[7],0);		
			clk_cb.ccip_tx.c0.valid <= 0;
	 `SVTEST_END 
      
	
	  
	`SVTEST(C0TX_ADDR_ZERO_WARN )
			reset();
			##1;
			clk_cb.ccip_tx.c2.mmioRdValid <= 0;
			
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= eREQ_RDLINE_I;
			clk_cb.ccip_tx.c0.hdr.address <= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[12],1);
			clk_cb.ccip_tx.c0.valid <= 0;
			##1;
		`SVTEST_END
	  
	   `SVTEST(XZ_FOUND_WARN)
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid <= 1;
			clk_cb.ccip_tx.c0.hdr	<= 2'bx;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[10],1);
			
			clk_cb.ccip_tx.c0.valid <= 0;
			reset();
			##1;
			clk_cb.ccip_tx.c1.valid <= 1;
			clk_cb.ccip_tx.c1.hdr	<= eREQ_WRLINE_M;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[10],0);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[19],1);
			
			clk_cb.ccip_tx.c1.valid <= 0;
			reset();
			##1;
			clk_cb.ccip_tx.c2.mmioRdValid <= 1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[19],0);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[4],1);
			clk_cb.ccip_tx.c2.mmioRdValid <= 0;
			
	  `SVTEST_END
	  
	  `SVTEST(C0TX_3CL_REQUEST)
			reset();
			##1;
			clk_cb.ccip_tx.c0.valid 	 <= 1;
			clk_cb.ccip_tx.c0.hdr		 <= eREQ_RDLINE_I;
			clk_cb.ccip_tx.c0.hdr.cl_len <= 2'b10;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[11],1);
			
	  `SVTEST_END 
	  
	  // ---------------------------------------------------------------------- //
	  // -------------------------- Write Channel Test ------------------------ //
	  // ---------------------------------------------------------------------- //
	`SVTEST(C1TX_INVALID_REQTYPE)
			reset();
			##1;
			clk_cb.ccip_tx.c1.valid		   <= 1;
			clk_cb.ccip_tx.c1.hdr.req_type <= eREQ_WRLINE_M;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[14],0);
			
			reset();
			##1;
			clk_cb.ccip_tx.c1.hdr.req_type <= eREQ_WRLINE_I; 
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[14],0);
			
			reset();
			##1;
			clk_cb.ccip_tx.c1.hdr.req_type	<= eREQ_WRFENCE;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[14],0);
			
			reset();
			##1;
			clk_cb.ccip_tx.c1.hdr.req_type <= eREQ_WRPUSH_I;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[14],0);
			
			reset();
			##1;
			clk_cb.ccip_tx.c1.hdr.req_type 	<= 4'h3;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[14],1);
	  `SVTEST_END
	  
	  `SVTEST(C1TX_OVERFLOW )
			reset();			
			clk_cb.ccip_tx.c1.valid 	<= 1;
			clk_cb.cf2as_ch1_realfull 	<= 1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[15],1);	
			##1;
			
			reset();			
			clk_cb.cf2as_ch1_realfull 	<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[15],0);	
			##1;			
	
	 `SVTEST_END
	 
	  `SVTEST(C1TX_ADDRALIGN_2 )
			reset();
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.req_type 	<= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01; 
			clk_cb.ccip_tx.c1.hdr.address		    <= 1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[16],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.valid   				<= 0;
			##1;
	  `SVTEST_END	 
	  
	  `SVTEST(C1TX_ADDR_ZERO_WARN )
			reset();
			##1;
			clk_cb.ccip_tx.c1.valid 		<= 1;
			clk_cb.ccip_tx.c1.hdr			<= eREQ_WRPUSH_I;
			clk_cb.ccip_tx.c1.hdr.address 	<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[29],1);
			clk_cb.ccip_tx.c1.valid 		<= 0;
			##1;
		`SVTEST_END
	   
	   `SVTEST(C1TX_ADDRALIGN_4)
			reset();
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.req_type 			<= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11; 
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[17],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.valid   				<= 0;
			##1;
	   `SVTEST_END
	   
	    `SVTEST(C1TX_UNEXP_VCSEL)
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			clk_cb.ccip_tx.c1.data 					<= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd2				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd1				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd0				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VH0;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[20],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			
			
	        ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRFENCE; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VH0;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[20],0);
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VH0;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[20],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VH0;			
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[20],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VH0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;		
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[20],1);
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VH0;			
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[20],1);

			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			#1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[20],0); 
			
		`SVTEST_END
		
		`SVTEST(C1TX_UNEXP_MDATA)
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			clk_cb.ccip_tx.c1.data 					<= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd2				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd1				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd0				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[21],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRFENCE; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 2;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[21],0);
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 3;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[21],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 4;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[21],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 5;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;		
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[21],1);
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 6;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[21],1);

			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			#1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[21],0);
			
		`SVTEST_END
		
		`SVTEST(C1TX_UNEXP_REQTYPE)
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			clk_cb.ccip_tx.c1.data 					<= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd2				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd1				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd0				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRLINE_I; 
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[24],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			
			
	        ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRLINE_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRFENCE;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[24],0);
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.req_type			<= eREQ_WRLINE_I;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[24],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRLINE_I;	
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[24],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRLINE_I;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;		
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[24],1);
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRLINE_I;	
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[24],1);

			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			#1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[24],0); 
		
		`SVTEST_END
		
		`SVTEST(C1TX_UNEXP_CLLEN)
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			clk_cb.ccip_tx.c1.data 					<= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd2				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd1				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd0				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[23],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			
			
	        ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11; 
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[23],0);
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01; 
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[23],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01; 
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[23],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01; 
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;		
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[23],1);
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01; 
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[23],1);

			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			#1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[23],0); 
		`SVTEST_END
		
		`SVTEST(C1TX_SOP_NOT_SET)
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRPUSH_I;  
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[25],1);
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[25],0);
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRFENCE; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[25],0);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[25],1);
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[25],0);			
		
		`SVTEST_END
		
		`SVTEST(C1TX_SOP_SET_MCL1TO3)
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			clk_cb.ccip_tx.c1.data 					<= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd2				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd1				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd0				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[26],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
						
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1; 			
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[26],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1; 
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[26],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;		
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[26],1);
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[26],1);

			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			#1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[26],0); 
		
		`SVTEST_END
		
		`SVTEST(C1TX_WRFENCE_SOP_SET)
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[26],0);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[30],1);
		`SVTEST_END
		
		`SVTEST(C1TX_WRFENCE_IN_MCL1TO3)
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			clk_cb.ccip_tx.c1.data 					<= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd2				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd1				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd0				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[28],1);
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			
			
	        ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 3;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[28],0);
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[28],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[28],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;		
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[28],1);
			
			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[28],1);

			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			#1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[28],0); 			
		
		`SVTEST_END
		
		`SVTEST(C1TX_3CL_REQUEST)
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b10;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			clk_cb.ccip_tx.c1.data 					<= 3;
			clk_cb.ccip_tx.c1.hdr.mdata				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd2				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd1				<= 0;
			clk_cb.ccip_tx.c1.hdr.rsvd0				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[27],1);
			clk_cb.ccip_tx.c1.valid   				<= 0;
			clk_cb.ccip_tx.c0.valid   				<= 0;
		
		`SVTEST_END
		
		
		`SVTEST(C1TX_UNEXP_ADDR)
	
	       ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <=  eREQ_WRFENCE; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[22],0);
			
			/*		reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.address		    <= 2;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##2;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[22],1);
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b01;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;*/
			
			#1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[22],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[22],1);
			
			 ##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;	
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[22],1);
			
		/*	##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[22],1);*/
			

			##1;
			reset();
			clk_cb.ccip_tx.c1.valid   				<= 1;
			clk_cb.ccip_tx.c1.hdr.sop				<= 1;
			clk_cb.ccip_tx.c1.hdr.vc_sel			<= eVC_VL0;
			clk_cb.ccip_tx.c1.hdr.req_type          <= eREQ_WRPUSH_I; 
			clk_cb.ccip_tx.c1.hdr.cl_len 			<= 2'b11;
			clk_cb.ccip_tx.c1.hdr.address		    <= 4;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 5;
			clk_cb.ccip_tx.c1.hdr.sop				<= 0;
			##1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 6;
			#1;
			clk_cb.ccip_tx.c1.hdr.address		    <= 7;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[22],0); 
			clk_cb.ccip_tx.c1.valid   				<= 0;
		`SVTEST_END		

		`SVTEST(MMIO_RDRSP_UNSOLICITED)
			reset();
			clk_cb.SoftReset <=1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[2],0);
			clk_cb.SoftReset <=0;
			##1;
			clk_cb.ccip_tx.c2.mmioRdValid <= 1;
			clk_cb.ccip_tx.c2.hdr.tid     <= 2; 
			clk_cb.ccip_tx.c2.data		  <= 3;
			
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[2],1);	
			clk_cb.ccip_tx.c2.mmioRdValid <= 0;
			
		`SVTEST_END	
		
		
		`SVTEST(MMIO_RDRSP_TIMEOUT)
			reset();
			clk_cb.ase_reset <=1;
			##3;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[1],0);
			clk_cb.ase_reset <=0;
			
			##1;
			for( int i=0;i<512;i++)
			begin
			reset();
			clk_cb.ccip_rx.c0.mmioRdValid <= 1;
			clk_cb.ccip_rx.c0.hdr    <= i;
			##512;
			##4;
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[1],1);
			end			
		`SVTEST_END	
		
		`SVTEST(C0TX_RESET_IGNORED)
			reset();
	        ##1;			
		    clk_cb.ccip_tx.c2.mmioRdValid <= 1;
			clk_cb.SoftReset <=1;
			##3;			
		//	`FAIL_UNLESS_EQUAL(clk_cb.error_code[9],1);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[13],0);
			`FAIL_UNLESS_EQUAL(clk_cb.error_code[7],0);	
			##1;
			clk_cb.ccip_tx.c0.valid <= 0;
			clk_cb.SoftReset <=0;
	  `SVTEST_END
		
	  `SVUNIT_TESTS_END

endmodule
