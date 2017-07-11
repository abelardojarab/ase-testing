#!/bin/bash

if [[ "$1" == "" ]];
then
    echo "** ERROR : Incorrect usage ! **"
    echo "Usage: ./start_simulator.sh <VCS|QUESTA>"
    exit 1
elif [[ "$1" != "VCS" ]]; 
then
    if [[ "$1" != "QUESTA" ]];
    then
	echo "** ERROR : Incorrect option ! **"
	echo "Usage: ./start_simulator.sh <VCS|QUESTA>"
	exit 1
    fi
fi
echo "Starting simulator ..."
cd $ASE_SRCDIR
make sim SIMULATOR=$1
