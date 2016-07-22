#!/bin/sh

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

echo "######################################"
echo "#     Testing Hello_ALI_VTP_NLB      #"
echo "######################################"
cd $BBB_GIT/BBB_ccip_mux/sample/sw/
make -f Makefile.4nlb prefix=$MYINST_DIR
timeout 600 ./helloALInlb
if [[ $? != 0 ]]; 
then
    "helloALInlb timed out -- FAILURE EXIT !!"
    exit 1
fi


