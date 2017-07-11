#!/bin/bash

TOOLKEY=$1

TOOLKEY_LIST="vcsmx_H_2013_06_SP1_15  vcsmx_J_2014_12_SP3_5  vcsmx_K_2015_09_SP1  vcsmx_L_2016_06  vsim_questasim_10_5b  vsim_modelsim_se_10_5a  vcs_I_2014_03  vsim_modelsim_se_10_3e  vsim_questasim_10_4d  vsim_modelsim_ae_16_0_0_211 vsim_modelsim_ase_17_0_0_290"

## Check if TOOLKEY is supplied
if [ "$1" = "" ];
then
    echo "** ERROR : Incorrect usage ! **"
    echo "Usage: source tools_setup.sh <TOOLKEY>"
    echo "    TOOLKEY      = $TOOLKEY_LIST"
    return 1
elif [[ "$1" =~ $TOOLKEY_LIST ]];
then
    echo "Unknown toolkey $TOOLKEY"
    echo "** ERROR : Incorrect usage ! **"
    echo "Usage: source tools_setup.sh <TOOLKEY>"
    echo "    TOOLKEY      = $TOOLKEY_LIST"
    return 1
else
    echo "Toolkey identified as $TOOLKEY"
fi


declare -A TOOL_PATH
declare -A TOOL_CLASS

## Set up VCS/Modelsim based on TOOLKEY
TOOL_PATH["vcsmx_H_2013_06_SP1_15"]="/opt/synopsys/vcs-mx/H-2013.06-SP1-15/"
TOOL_PATH["vcsmx_J_2014_12_SP3_5"]="/opt/synopsys/vcs-mx/J-2014.12-SP3-5/"
TOOL_PATH["vcsmx_K_2015_09_SP1"]="/opt/synopsys/vcs-mx/K-2015.09-SP1/"
TOOL_PATH["vcsmx_L_2016_06"]="/opt/synopsys/vcs-mx/L-2016.06/"
TOOL_PATH["vsim_questasim_10_5b"]="/opt/mentor/questasim_10.5b/questasim/"
TOOL_PATH["vsim_modelsim_se_10_5a"]="/opt/mentor/modelsim_se_10.5a/modeltech"
TOOL_PATH["vcs_I_2014_03"]="/opt/synopsys/vcs/I-2014.03/"
TOOL_PATH["vsim_modelsim_se_10_3e"]="/opt/mentor/modelsim_se_10.3e/modeltech/"
TOOL_PATH["vsim_questasim_10_4d"]="/opt/mentor/questasim_10.4d/questasim/"
TOOL_PATH["vsim_modelsim_ae_16_0_0_211"]="/opt/mentor/modelsim_ae-16.0.0.211/modelsim_ae/"
TOOL_PATH["vsim_modelsim_ase_17_0_0_290"]="/opt/altera/17.0.0.290/modelsim_ase/"

TOOL_CLASS["vcsmx_H_2013_06_SP1_15"]=VCS
TOOL_CLASS["vcsmx_J_2014_12_SP3_5"]=VCS
TOOL_CLASS["vcsmx_K_2015_09_SP1"]=VCS
TOOL_CLASS["vcsmx_L_2016_06"]=VCS
TOOL_CLASS["vsim_questasim_10_5b"]=QUESTA
TOOL_CLASS["vsim_modelsim_se_10_5a"]=QUESTA
TOOL_CLASS["vcs_I_2014_03"]=VCS
TOOL_CLASS["vsim_modelsim_se_10_3e"]=QUESTA
TOOL_CLASS["vsim_questasim_10_4d"]=QUESTA
TOOL_CLASS["vsim_modelsim_ae_16_0_0_211"]=QUESTA
TOOL_CLASS["vsim_modelsim_ase_17_0_0_290"]=QUESTA

## Set path
export SELECTED_PATH=${TOOL_PATH["$TOOLKEY"]}
export SELECTED_CLASS=${TOOL_CLASS["$TOOLKEY"]}
echo "SELECTED_PATH  : " $SELECTED_PATH
echo "SELECTED_CLASS : " $SELECTED_CLASS

## Check if Release Code is supplied
export ALTERA_VER=17.0.0.290
if [ "$RELCODE" = "SKX1" ];
then
    export ALTERA_VER="17.0.0.290"
    export RELCODE="SKX1"
elif [ "$RELCODE" = "BDX2" ];
then
    export ALTERA_VER="16.0.0.211-Pro"
    export RELCODE="BDX2"
elif [ "$RELCODE" = "BDX1" ];
then
    export ALTERA_VER="15.1.2"
    export RELCODE="BDX1"
fi

## Set LM_PROJECT
export LM_PROJECT="ATP-PLAT-DEV"

## Set paths
if [ "$SELECTED_CLASS" = "VCS" ];
then
    ## Synopsys license
    export SNPSLMD_LICENSE_FILE="26586@plxs0402.pdx.intel.com:26586@plxs0405.pdx.intel.com:26586@plxs0406.pdx.intel.com:26586@plxs0408.pdx.intel.com:26586@plxs0414.pdx.intel.com:26586@plxs0415.pdx.intel.com:26586@plxs0416.pdx.intel.com:26586@plxs0418.pdx.intel.com:26586@synopsys69p.elic.intel.com:26586@synopsys68p.elic.intel.com:26586@fmylic43.fm.intel.com:26586@irslic006.ir.intel.com"
    export VCS_HOME=$SELECTED_PATH
elif [ "$SELECTED_CLASS" = "QUESTA" ];
then
    ## Mentor License
    export MGLS_LICENSE_FILE="1717@mentor04p.elic.intel.com"
    export MTI_HOME=$SELECTED_PATH
else
    echo "** ERROR: TOOL_CLASS=$SELECTED_CLASS is unidentified ! EXIT here ! **"
    return 1
fi

if [ "$TOOLKEY" = "vsim_modelsim_ae_16_0_0_211" ] || [ "$TOOLKEY" = "vsim_modelsim_ase_17_0_0_290" ] ;
then
    echo "Using 'linux' instead of 'bin'"
    export PATH=${SELECTED_PATH}/linux/:${PATH}
else
    export PATH=${SELECTED_PATH}/bin/:${PATH}
fi

export SIMULATOR=$SELECTED_CLASS

## Setup Altera settings
export LM_LICENSE_FILE=$LM_LICENSE_FILE:"1800@fmylic36b.fm.intel.com:1800@fmylic7001.fm.intel.com:1800@fmylic7008.fm.intel.com"
# export LM_LICENSE_FILE=$LM_LICENSE_FILE:"1800@altera02p.elic.intel.com:1800@dan-host-1.sc.intel.com:1800@plxs0402.pdx.intel.com"
export QUARTUS_HOME=/opt/altera/$ALTERA_VER/quartus/
export QUARTUS_ROOTDIR=$QUARTUS_HOME
export QUARTUS_64BIT=1
export QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_HOME
export ALTERAOCLSDKROOT="/opt/altera/$ALTERA_VER/hld/"
export PATH=$QUARTUS_HOME/bin/:$QUARTUS_HOME/../hld/bin/:$PATH

## License file path
export LD_LIBRARY_PATH=$BBB_GIT/BBB_cci_mpf/sw/

## Print variables
echo "QUARTUS_HOME         : " $QUARTUS_HOME
echo "VCS_HOME             : " $VCS_HOME
echo "MTI_HOME             : " $MTI_HOME
echo "SNPSLMD_LICENSE_FILE : " $SNPSLMD_LICENSE_FILE
echo "MGLS_LICENSE_FILE    : " $MGLS_LICENSE_FILE
echo "PATH                 : " $PATH
echo "LD_LIBRARY_PATH      : " $LD_LIBRARY_PATH
# echo "LM_LICENSE_FILE      : " $LM_LICENSE_FILE
