#!/bin/bash

# set -v

./clean.sh

# gcc -g -o test_inotify test_inotify.c

gcc -g -o running_tally.out running_tally.c -I $ASE_SRCDIR/sw -fprofile-arcs -ftest-coverage -lgcov

gcc -g -o seeded_random seeded_random.c -I $ASE_SRCDIR/sw

gcc -g -o afuid afuid.c -I $ASE_SRCDIR/api/include -I $ASE_SRCDIR/sw $MYINST_DIR/lib/libopae-c-ase.so -luuid

