#!/bin/sh

## Questasim settings
export MTI_HOME=/opt/mentor/questasim/
export PATH=$MTI_HOME/linux_x86_64/:$PATH

## Modelsim settings
# export MTI_HOME=/opt/altera/15.1.2/modelsim_ase/
# export PATH=$MTI_HOME/linux/:$PATH

export MGLS_LICENSE_FILE="1717@mentor04p.elic.intel.com"
export LM_LICENSE_FILE="1717@mentor04p.elic.intel.com":$LM_LICENSE_FILE
export LM_PROJECT="ATP-PLAT-DEV"
