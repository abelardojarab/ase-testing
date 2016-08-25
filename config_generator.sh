#!/bin/sh

# Usage ./config_generator.sh <single|multi> <seed!=0> <silent|noisy> <usrclk> <mem>

type=$1
seed=$2
verbose=$3
fclk=$4
mem=$5

if [ $type=="single" ] 
then
    echo -e -n "ASE_MODE = 3\n" 
    echo -e -n "ASE_TIMEOUT = 50000\n"
    echo -e -n "ASE_NUM_TESTS = 500\n"
elif [ $type=="multi" ]
then
    echo -e -n "ASE_MODE = 1\n" 
    echo -e -n "ASE_TIMEOUT = 50000\n"
    echo -e -n "ASE_NUM_TESTS = 500\n"
fi


if [ $seed -eq 0 ]
then
    echo -e -n "ENABLE_REUSE_SEED = 0\n"
    echo -e -n "ASE_SEED = 1234\n"
else 
    echo -e -n "ENABLE_REUSE_SEED = 1\n"
    echo -e -n "ASE_SEED = $seed\n"
fi


if [ $verbose=="silent" ] 
then
    echo -e -n "ENABLE_CL_VIEW = 0\n"
elif [ $verbose=="noisy"]
then
    echo -e -n "ENABLE_CL_VIEW = 1\n"
fi

echo -e -n "USR_CLK_MHZ = $fclk\n"
echo -e -n "PHYS_MEMORY_AVAILABLE_GB = $mem\n"
