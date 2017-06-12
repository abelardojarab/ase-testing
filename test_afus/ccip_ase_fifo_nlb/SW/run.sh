#!/bin/sh

set -e

FIFO_DIR=$PWD
LD_LIBRARY_PATH=$MYINST_DIR/lib/
cd $FIFO_DIR/../config/SKX1/FIFO
ls $FIFO_DIR/../config/SKX1/FIFO
# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"

cd $FIFO_DIR/../config/SKX1/FIFO
make ase_svfifo
make sim




