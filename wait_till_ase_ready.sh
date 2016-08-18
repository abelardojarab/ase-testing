#!/bin/sh

# Wait for Simulator to be running/ready
echo "Waiting for simulator to be ready (will wait > 10 mins) ... "
for sleep in `seq 0 600`;
do
    if [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
    then
	sleep 1
    fi
done
if [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
then
    echo "Simulator might probably not come up at all -- ending regression here !"
    exit 1
fi
echo "DONE"

