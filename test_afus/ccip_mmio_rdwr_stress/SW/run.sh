#!/bin/sh

# make prefix=$MYINST_DIR

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

/usr/bin/timeout 1800 ./mmio_stress
errcode=$?
if [[ $errcode != 0 ]]
then
    echo "** mmio_stress: FAILURE EXIT !! Error code $errcode **"
    exit 1
fi
