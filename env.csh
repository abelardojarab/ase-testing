setenv BASEDIR /nfs/pdx/disks/atp.06/user/rrsharma/xeon-fpga-src

setenv AALSDK_GIT $BASEDIR/aalsdk
setenv ASEVAL_GIT $BASEDIR/ase_regression
setenv BBB_GIT    $BASEDIR/BuildingBlocks

setenv AALUSER_DIR $AALSDK_GIT/aaluser
setenv ASE_SRCDIR  $AALSDK_GIT/aaluser/ase
setenv ASE_WORKDIR $AALSDK_GIT/aaluser/ase/work
setenv AALKERN_DIR $AALSDK_GIT/aalkernel
setenv MYINST_DIR  $BASEDIR/myinst
setenv AALSAMP_DIR $AALSDK_GIT/aalsamples

echo "Directory settings =>"
echo "AALSDK_GIT  : " $AALSDK_GIT
echo "ASEVAL_GIT  : " $ASEVAL_GIT
echo "BBB_GIT     : " $BBB_GIT
echo "AALUSER_DIR : " $AALUSER_DIR
echo "AALUSER_DIR : " $AALUSER_DIR
echo "ASE_SRCDIR  : " $ASE_SRCDIR
echo "ASE_WORKDIR : " $ASE_WORKDIR
echo "AALKERN_DIR : " $AALKERN_DIR
echo "MYINST_DIR  : " $MYINST_DIR
echo "AALSAMP_DIR : " $AALSAMP_DIR

