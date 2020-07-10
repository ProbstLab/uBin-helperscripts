#!/bin/bash

if [ "$#" -lt 5 ]
then
  	echo "usage: map.sh <input-fasta> <fwd_fastq> <rev_fastq> <threads> <directory>"
	exit 1
fi

assembly=$1
read1=$2
read2=$3
threads=$4
dir=$5
echo "creating mapping index"
mkdir bt2
bowtie2-build $assembly bt2/$assembly > bt2/$assembly.log

echo "mapping..."
nice bowtie2 -p $threads  --no-unal --sensitive -x bt2/$assembly -1 $read1 -2 $read2 2> $assembly.sam.log > $assembly.sam

echo "calculating coverage..."
ruby $dir/04_01calc_coverage_v3.rb -s $assembly.sam -f $assembly | sort -k1,1 > $assembly.scaff2cov.txt

echo "calculating GC content..."
ruby $dir/04_02gc_count.rb -f $assembly | sort -k1,1 > $assembly.scaff2gc.txt

echo "parsing length of each scaffold..."
ruby $dir/04_03fasta_length_individual.rb -f $assembly | sort -k1,1 > $assembly.scaff2len.txt

echo "cleaning up..."
rm $assembly.sam
rm -r bt2

echo "...done!"
