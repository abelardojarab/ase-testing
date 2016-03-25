#!/bin/bash

machine=$(uname -n)
machine=${machine,,}

dist_id=$(lsb_release -i -s)
dist_id=${dist_id,,}

echo "$dist_id"
echo "$machine"

if [ "$machine" == "atp-ase1" ]
then
    source /opt/altera/quartus_15.sh
    source /opt/synopsys/vcs-mx/vcs.sh
    source /opt/mentor/modelsim_se_10_5.sh
    # source /opt/mentor/questasim_10_3.sh
elif [ "$dist_id" == "suse linux" ]
then
    source /nfs/pdx/home/rrsharma/bashrc_aliases/quartus_15_pro.csh
    source /nfs/pdx/home/rrsharma/bashrc_aliases/vcs.csh
    source /nfs/pdx/home/rrsharma/bashrc_aliases/questasim.sh    
fi

echo "QUARTUS_HOME    : " $QUARTUS_HOME
echo "VCS_HOME        : " $VCS_HOME
echo "MTI_HOME        : " $MTI_HOME
echo "LM_LICENSE_FILE : " $LM_LICENSE_FILE
