#!/bin/bash

# Wait for Simulator to be running/ready
echo "Waiting for simulator to be ready (will wait > 10 mins) ... "
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done
echo "DONE"

