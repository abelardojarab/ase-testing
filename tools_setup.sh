#!/bin/sh

if [[ "$1" == "" ]];
then
    echo "** ERROR : Incorrect usage ! **"
    echo "Usage: source tools_setup.sh <TOOLKEY>"
    exit 1
fi

TOOLKEY=$1

declare -A TOOL_PATH
declare -A TOOL_CLASS

## Set up VCS/Modelsim based on TOOLKEY
TOOL_PATH=([vcsmx_H_2013_06_SP1_15]="/opt/synopsys/vcs-mx/H-2013.06-SP1-15/" [vcsmx_J_2014_12_SP3_5]="/opt/synopsys/vcs-mx/J-2014.12-SP3-5/" [vcsmx_K_2015_09_SP1]="/opt/synopsys/vcs-mx/K-2015.09-SP1/" [vcsmx_L_2016_06]="/opt/synopsys/vcs-mx/L-2016.06/" [vsim_questasim_10_5b]="/opt/mentor/questasim_10.5b/questasim/" [vsim_modelsim_se_10_5a]="/opt/mentor/modelsim_se_10.5a/modeltech" [vcs_I_2014_03]="/opt/synopsys/vcs/I-2014.03/" [vsim_modelsim_se_10_3e]="/opt/mentor/modelsim_se_10.3e/modeltech/" [vsim_questasim_10_4d]="/opt/mentor/questasim_10.4d/questasim/")

TOOL_CLASS=([vcsmx_H_2013_06_SP1_15]=VCS [vcsmx_J_2014_12_SP3_5]=VCS [vcsmx_K_2015_09_SP1]=VCS [vcsmx_L_2016_06]=VCS [vsim_questasim_10_5b]=QUESTA [vsim_modelsim_se_10_5a]=QUESTA [vcs_I_2014_03]=VCS [vsim_modelsim_se_10_3e]=QUESTA [vsim_questasim_10_4d]=QUESTA)

## Set path
export SELECTED_PATH=${TOOL_PATH[$TOOLKEY]}
export SELECTED_CLASS=${TOOL_CLASS[$TOOLKEY]}
echo $SELECTED_PATH
echo $SELECTED_CLASS

## Set paths
if [[ "$SELECTED_CLASS" == "VCS" ]] ; 
then
    ## Synopsys license
    export SNPSLMD_LICENSE_FILE="26586@plxs0402.pdx.intel.com:26586@plxs0405.pdx.intel.com:26586@plxs0406.pdx.intel.com:26586@plxs0408.pdx.intel.com:26586@plxs0414.pdx.intel.com:26586@plxs0415.pdx.intel.com:26586@plxs0416.pdx.intel.com:26586@plxs0418.pdx.intel.com"    
    export VCS_HOME=$SELECTED_PATH
    export PATH=${VCS_HOME}/bin/:${PATH}
elif [[ "$SELECTED_CLASS" == "QUESTA" ]] ;
then
    ## Mentor License
    export MGLS_LICENSE_FILE="1717@mentor04p.elic.intel.com"
    export LM_PROJECT="ATP-PLAT-DEV"
    export MTI_HOME=$SELECTED_PATH
    export PATH=${MTI_HOME}/bin/:${PATH}
else
    echo "** ERROR: TOOLKEY=$TOOLKEY is unidentified ! EXIT here ! **"
    exit 1
fi
export SIMULATOR=$SELECTED_CLASS

## Setup Altera settings
export LM_LICENSE_FILE=$LM_LICENSE_FILE:"1800@fmylic36b.fm.intel.com:1800@fmylic7001.fm.intel.com:1800@fmylic7008.fm.intel.com"
export LM_LICENSE_FILE=$LM_LICENSE_FILE:"1800@altera02p.elic.intel.com:1800@dan-host-1.sc.intel.com:1800@plxs0402.pdx.intel.com"
export QUARTUS_HOME=/opt/altera/15.1.2/quartus/
export QUARTUS_ROOTDIR=$QUARTUS_HOME
export QUARTUS_64BIT=1
export QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_HOME
export ALTERAOCLSDKROOT="/opt/altera/15.1.2/hld/"
export PATH=$PATH:$QUARTUS_HOME/bin/:$QUARTUS_HOME/../hld/bin/

## License file path
export LD_LIBRARY_PATH=$BBB_GIT/cci_mpf/SW/ 

## Print variables
echo "QUARTUS_HOME         : " $QUARTUS_HOME
echo "VCS_HOME             : " $VCS_HOME
echo "MTI_HOME             : " $MTI_HOME
echo "SNPSLMD_LICENSE_FILE : " $SNPSLMD_LICENSE_FILE
echo "MGLS_LICENSE_FILE    : " $MGLS_LICENSE_FILE
echo "PATH                 : " $PATH
echo "LD_LIBRARY_PATH      : " $LD_LIBRARY_PATH
echo "LM_LICENSE_FILE      : " $LM_LICENSE_FILE

