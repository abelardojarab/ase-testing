module __testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "__ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  ccip_checker_unit_test ccip_checker_ut();


  //===================================
  // Build
  //===================================
  function void build();
    ccip_checker_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(ccip_checker_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    ccip_checker_ut.run();
    svunit_ts.report();
  endtask

endmodule
