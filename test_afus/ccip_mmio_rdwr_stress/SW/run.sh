#!/bin/sh

make prefix=$MYINST_DIR

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

timeout 300 ./mmio_stress
if [[ $? != 0 ]]; 
then
    "mmio_stress: FAILURE EXIT !!"
    exit 1
fi


