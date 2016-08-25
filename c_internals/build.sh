#!/bin/sh

# set -v

./clean.sh

# gcc -g -o test_inotify test_inotify.c

gcc -g -o running_tally.out running_tally.c -I $ASE_SRCDIR/sw -fprofile-arcs -ftest-coverage -lgcov

gcc -g -o seeded_random seeded_random.c -I $ASE_SRCDIR/sw
