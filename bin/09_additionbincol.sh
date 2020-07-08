#!/bin/bash - 
#===============================================================================
#
#          FILE: additionbincol.sh
# 
#         USAGE: ./additionbincol.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 04/01/20 12:54
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
scaf2bin=$1
overview=$2
## assumes that both have the same names
# not tested yet so maybe verify
awk 'NR==FNR{set[$1]=$2} NR!=FNR && FNR==1{print $0"\tBin"} NR!=FNR && FNR!=1 {print $0"\t"set[$1]}' $scaf2bin $overview

