#!/bin/sh

SKXP_DIR="/nfs/pdx/disks/atp.06/user/rrsharma/xeon-fpga-src/skxp-a0/"
RX_PERSONS="rahul.r.sharma@intel.com"
EXEC_AT=`date`

cd $SKXP_DIR
git pull | tee pull.log
echo "Updated $SKXP_DIR at $EXEC_AT" |  mail -s "[Automated] SKXP Watcher output" -a pull.log $RX_PERSONS
rm pull.log

