#!/bin/sh

# set -v

./clean.sh

# gcc -g -o test_inotify test_inotify.c

gcc -g -o running_tally.out running_tally.c -I ../../aalsdk/aaluser/ase/sw -fprofile-arcs -ftest-coverage -lgcov

