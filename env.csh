

if ( $1 == "") then
    setenv BASEDIR /nfs/pdx/disks/atp.06/user/rrsharma/xeon-fpga-src
else
    setenv BASEDIR $1
endif

setenv FPGASW_GIT $BASEDIR/fpga-sw
setenv ASEVAL_GIT $BASEDIR/ase_regression
setenv BBB_GIT    $BASEDIR/BuildingBlocks

setenv ASE_SRCDIR  $FPGASW_GIT/aaluser/ase
setenv ASE_WORKDIR $FPGASW_GIT/aaluser/ase/work
setenv MYINST_DIR  $BASEDIR/myinst
setenv PLATFORM_DIR $MYINST_DIR/share/opae/platform

setenv RELCODE     "SKX1"

setenv PATH ${PATH}:$MYINST_DIR/bin
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:$MYINST_DIR/lib

echo "Directory settings =>"
echo "FPGASW_GIT      : " $FPGASW_GIT
echo "ASEVAL_GIT      : " $ASEVAL_GIT
echo "BBB_GIT         : " $BBB_GIT
echo "ASE_SRCDIR      : " $ASE_SRCDIR
echo "ASE_WORKDIR     : " $ASE_WORKDIR
echo "MYINST_DIR      : " $MYINST_DIR
echo "PLATFORM_DIR    : " $PLATFORM_DIR
echo "RELCODE         : " $RELCODE
echo "PATH            : " $PATH
echo "LD_LIBRARY_PATH : " $LD_LIBRARY_PATH
