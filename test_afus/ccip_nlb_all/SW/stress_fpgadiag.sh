#!/bin/sh

cd $MYINST_DIR/bin
for i in `seq 0 10000`; do
    echo "---------------------------------"
    echo " Iteration $i                    "
    echo "---------------------------------"
    gdb -ex run -ex quit --args ./fpgadiag --target=ase --mode=lpbk1 --begin=1
done

