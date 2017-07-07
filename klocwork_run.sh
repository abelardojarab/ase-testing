#!/bin/sh

# export PATH=/home/rrsharma/kw10/bin:$PATH
export PATH=/home/rrsharma/klocwork/bin:${PATH}
# export KW_BUILD=$AALUSER_DIR/kw_build/
export KW_BUILD=$ASEVAL_GIT/kw_build/

############################################################################
# delete and rebuild KWbuild
rm -rf $KW_BUILD
mkdir -p $KW_BUILD
cd $KW_BUILD

rm -rf $ASEVAL_GIT/kw_run.*
kwcheck create --url https://klocwork-jf3.devtools.intel.com:8085/FPGA_API_ASE
# kwcheck create --url https://klocwork-jf3.devtools.intel.com:8085/BBB
kwinject $ASEVAL_GIT/sw_build_all.sh lib_only
kwinject $ASEVAL_GIT/dummy_swbuild.sh

kwcheck run --build-spec kwinject.out --local
kwcheck list -F detailed --local --system --severity 1 > $ASEVAL_GIT/kw_run.1.log
kwcheck list -F detailed --local --system --severity 2 > $ASEVAL_GIT/kw_run.2.log
kwcheck list -F detailed --local --system --severity 3 > $ASEVAL_GIT/kw_run.3.log
kwcheck list -F detailed --local --system --severity 4 > $ASEVAL_GIT/kw_run.4.log
kwcheck list -F detailed --local --system --severity 5 > $ASEVAL_GIT/kw_run.5.log
