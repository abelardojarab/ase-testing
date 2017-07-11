#!/bin/bash

# Wait for Simulator to be running/ready
echo "Waiting for simulator to be ready ... "
for sleep in `seq 0 180`;
do
    if [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
    then
	sleep 1
    fi
done

# Run valggrind app
valgrind -v --tool=memcheck \
    --leak-check=full \
    --track-origins=yes \
    --num-callers=20 \
    --error-limit=no \
    --log-file=valgrind.log \
    --track-fds=yes \
    --leak-check=full \
    --track-origins=yes \
    --show-reachable=yes \
    --show-leak-kinds=definite,possible \
    --undef-value-errors=yes \
    ./nlb_test.out

# 1024 0 3

