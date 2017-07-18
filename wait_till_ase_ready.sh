#!/bin/bash

# Wait for Simulator to be running/ready
echo "Waiting for simulator to be ready ... "
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done
echo "DONE"

