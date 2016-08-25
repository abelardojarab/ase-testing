#!/bin/sh

NUM_RUNS=2

ASE_CONFIG=$ASEVAL_GIT/test.cfg

./config_generator.sh single 1234 silent 300.000 64 > $ASE_CONFIG

## Build simulator
cd $ASE_SRCDIR
make ASE_DEBUG=0

for ii in `seq 1 $NUM_RUNS`
do
    echo "1234" > $ASE_WORKDIR/ase_seed.txt
    echo $ii
    ## Run simulator
    cd $ASE_SRCDIR
    make sim ASE_DEBUG=0 ASE_CONFIG=$ASE_CONFIG &
    $ASEVAL_GIT/wait_till_ase_ready.sh
    ## Run application
    cd $MYINST_DIR/bin/
    ./fpgadiag --target=ase --mode=lpbk1 --begin=32768
    ## Wait until Simulator shuts down
    while [ -f $ASE_WORKDIR/.ase_ready.pid ]
    do
    	sleep 1
    done
    ## Trim out transaction file
    cat $ASE_WORKDIR/ccip_transactions.tsv | cut -s -f2- | grep -v SoftReset | grep -v ASE | grep -v HW | grep -v UMSG | grep -v Allocated | grep -v Workspace | grep -v Host  | less > $ASEVAL_GIT/random_test_log_$ii.txt
    cp $ASE_WORKDIR/ccip_transactions.tsv $ASEVAL_GIT/transactions_$ii.txt
done
