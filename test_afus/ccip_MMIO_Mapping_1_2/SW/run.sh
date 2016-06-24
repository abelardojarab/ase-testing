#!/bin/sh

# Application args array
app_arg_array="1 2"

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

# Build MMIO_Mapping test
cd $AALSDK_GIT/valapps/MMIO_Mapping/
make prefix=$MYINST_DIR

# For each application 
for arg in $app_arg_array ; do
    if ps -p $ase_pid > /dev/null
    then	
	./MMIO_Mapping $arg
	if [[ $? != 0 ]] ; 
	then
	    echo "MMIO_Mapping application failed !"
	    exit 1
	fi
    else
	echo "** Simulator not running **"
	exit 1
    fi    
done

