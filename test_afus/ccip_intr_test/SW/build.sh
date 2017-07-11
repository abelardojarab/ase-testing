#!/bin/bash

gcc -g -o hello_fpga_intr hello_fpga_intr.c $MYINST_DIR/lib/libopae-c-ase.so  -I $MYINST_DIR/include/ -std=c99 -luuid

