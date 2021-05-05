#!/bin/bash

if [ "$#" -lt 4 ]
then
  	echo "usage: bash 04_00map_mod_SRMod.sh <input-fasta> <fastq> <threads> <directory>"
	exit 1
fi

assembly=$1
reads=$2
threads=$3
dir=$4
assemblyfolder=$(dirname $assembly)
assemblybasename=$(echo $assembly | awk -F"/" '{print $NF}')
echo "creating mapping index"
mkdir $assemblyfolder/bt2
bowtie2-build $assembly $assemblyfolder/bt2/$assemblybasename > $assemblyfolder/bt2/$assemblybasename.log

echo "mapping..."
nice bowtie2 -p $threads  --no-unal --sensitive -x $assemblyfolder/bt2/$assemblybasename -U $reads 2> $assembly.sam.log > $assembly.sam

echo "calculating coverage..."
ruby $dir/04_01calc_coverage_v3.rb -s $assembly.sam -f $assembly | sort -k1,1 > $assembly.scaff2cov.txt

echo "calculating GC content..."
ruby $dir/04_02gc_count.rb -f $assembly | sort -k1,1 > $assembly.scaff2gc.txt

echo "parsing length of each scaffold..."
ruby $dir/04_03fasta_length_individual.rb -f $assembly | sort -k1,1 > $assembly.scaff2len.txt

echo "cleaning up..."
rm $assembly.sam
rm -r $assemblyfolder/bt2

echo "...done!"
