#!/bin/bash - 
#===============================================================================
#
#          FILE: 03_format_assembly.sh
# 
#         USAGE: ./03_format_assembly.sh {fasta} {project_sample}
# 
#   DESCRIPTION: takes a fasta file as input and modifies the header 
#                so that the general NODE is replaced by the Project_Sample name as supplied as the 
#                as the first argument. It also trims the decimals of the Kmer-Coverage calculated during assembly
#                and replaces any additional dots or dashes with underscores so that later binning doesnt require
	#	 further name modification
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: TB
#  ORGANIZATION: 
#       CREATED: 04/23/19 13:30
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [[ $# < 1 ]];then
	echo "USAGE: bash 03_format_assembly.sh {fasta} {project_sample}"
	exit 1
fi

fasta=$1
prefix=$2
#parttobereplaced=">NODE_"
minimumlength=1000
#sed -i "s/\.[0-9]\+$//g;s/$parttobereplaced/>${prefix}_/g;s/\./_/g;s/-/_/g" $fasta
pullseq -i $fasta -m $minimumlength > ${prefix}_min${minimumlength}.fasta
