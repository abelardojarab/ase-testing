To Create an executeable:
- Use make ase_svfifo; make sim 

To compile
- ./simv -cm -full64 line+fsm+cond+tgl+branch

For waveforms 
- dve -vpd inter.vpd -full64


Possible Violations in ase_fifo.sv

- RESET
  
  > More conditions for Write : ( !reset and write_en)

- FULL CONDITION
  
  > When Full Condition is asserted , make sure you are checking for !Read_en &&
    !Valid_out. Else, you will see Full being asserted even if read_en is high.
    
  > Fifo_size and Write_en sends Full high , what if the fifo_size() > DEPTH
  -1?? Full doesnt seem to be asserted.       
    
- WRITE CONDITION

  > Make sure you are writing into the FIFO , make sure the data is valid
  condition is checked too ( Valid_in). Else, irrespective of valid_in data gets
  written into the FIFO.
 
-OVERFLOW CONDITION
  
  > Make sure you either take care of all the corner cases of FULL conditions,
  then make Overflow dependant on FULL signal. Otherwise, you will notice that
  even though the FIFO is full, you will see data getting pushed in and the
  Overflow deasserted . 
  
-ALMOST FULL CONDITION

  > Wrong condition (DEPTH - ALMFULL_THRESH) . DEPTH =2^8 whereas 
  ALMFULL_THRESHOLD is 5 . 2^8 -5 will give as x Values at the output.Make
  almost Full threshold a power of 2.
  

  
