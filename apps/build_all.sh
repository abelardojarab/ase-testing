#!/bin/sh

COV_FLAGS="-fprofile-arcs -ftest-coverage -lgcov"

rm -rf *.out output.*.log

if [[ $1 != "" ]]
then
    ASE_SRCDIR=$1
else
    ASE_SRCDIR=../../aalsdk/aaluser/ase/
fi

set -v

gcc  -g -o nlb_test.out \
    nlb_lpbk1_test.c \
    ${ASE_SRCDIR}/sw/tstamp_ops.c \
    ${ASE_SRCDIR}/sw/ase_ops.c \
    ${ASE_SRCDIR}/sw/app_backend.c \
    ${ASE_SRCDIR}/sw/mqueue_ops.c \
    ${ASE_SRCDIR}/sw/error_report.c \
    -lrt -lm -lpthread -I ${ASE_SRCDIR}/sw/ \
#    -D ASE_DEBUG

gcc -g -o mmio_test.out \
    mmio_test.c \
    ${ASE_SRCDIR}/sw/tstamp_ops.c \
    ${ASE_SRCDIR}/sw/ase_ops.c \
    ${ASE_SRCDIR}/sw/app_backend.c \
    ${ASE_SRCDIR}/sw/mqueue_ops.c \
    ${ASE_SRCDIR}/sw/error_report.c \
    -lrt -lm -lpthread -I ${ASE_SRCDIR}/sw/ \
#    -D ASE_DEBUG

gcc  -g -o alloc_dealloc.out \
    alloc_dealloc.c \
    ${ASE_SRCDIR}/sw/tstamp_ops.c \
    ${ASE_SRCDIR}/sw/ase_ops.c \
    ${ASE_SRCDIR}/sw/app_backend.c \
    ${ASE_SRCDIR}/sw/mqueue_ops.c \
    ${ASE_SRCDIR}/sw/error_report.c \
    -lrt -lm -lpthread -I ${ASE_SRCDIR}/sw/ \
    -D ASE_DEBUG

gcc  -g -o alloc_stress_test.out \
    alloc_stress_test.c \
    ${ASE_SRCDIR}/sw/tstamp_ops.c \
    ${ASE_SRCDIR}/sw/ase_ops.c \
    ${ASE_SRCDIR}/sw/app_backend.c \
    ${ASE_SRCDIR}/sw/mqueue_ops.c \
    ${ASE_SRCDIR}/sw/error_report.c \
    -lrt -lm -lpthread -I ${ASE_SRCDIR}/sw/ \

# gcc -g -o mux_nlb_test.out \
#     mux_nlb_test.c \
#     ${ASE_SRCDIR}/sw/tstamp_ops.c \
#     ${ASE_SRCDIR}/sw/ase_ops.c \
#     ${ASE_SRCDIR}/sw/app_backend.c \
#     ${ASE_SRCDIR}/sw/mqueue_ops.c \
#     ${ASE_SRCDIR}/sw/error_report.c \
#     -lrt -lm -lpthread -I ${ASE_SRCDIR}/sw/ \
#     -D ASE_DEBUG

gcc  -g -o session_stress.out \
    session_stress.c \
    ${ASE_SRCDIR}/sw/tstamp_ops.c \
    ${ASE_SRCDIR}/sw/ase_ops.c \
    ${ASE_SRCDIR}/sw/app_backend.c \
    ${ASE_SRCDIR}/sw/mqueue_ops.c \
    ${ASE_SRCDIR}/sw/error_report.c \
    -lrt -lm -lpthread -I ${ASE_SRCDIR}/sw/ \

gcc  -g -o umsg_test.out \
    umsg_test.c \
    ${ASE_SRCDIR}/sw/tstamp_ops.c \
    ${ASE_SRCDIR}/sw/ase_ops.c \
    ${ASE_SRCDIR}/sw/app_backend.c \
    ${ASE_SRCDIR}/sw/mqueue_ops.c \
    ${ASE_SRCDIR}/sw/error_report.c \
    -lrt -lm -lpthread -I ${ASE_SRCDIR}/sw/ \


