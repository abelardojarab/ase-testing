module random_test ();


   integer seed = 12345;

   integer out;

   integer i ;


   initial begin
      // out = $fopen("rand.vec","w");

      $display( "seed = %h, 1st random number in hexadecimal = 0x%h", seed, $random(seed));

      $display( "seed = %h, 2nd random number in hexadecimal = 0x%h", seed, $random(seed));

      $display( "seed = %h, 3rd random number in hexadecimal = 0x%h", seed, $random(seed));

      $display( "seed = %h, 4th random number in hexadecimal = 0x%h", seed, $random(seed));

      $display( "seed = %h, 5th random number in hexadecimal = 0x%h", seed, $random(seed));

   end // initial begin

endmodule
