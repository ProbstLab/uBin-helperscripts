#!/bin/bash

if [ "$#" -lt 3 ]
then
  	echo "usage: map.sh <input-fasta> <singleread.fastq>"
	exit 1
fi

assembly=$1
read=$2
threads=$3

echo "creating mapping index"
mkdir bt2
bowtie2-build $assembly bt2/$assembly > bt2/$assembly.log

echo "mapping..."
nice bowtie2 -p $threads  --sensitive -x bt2/$assembly -U $read 2> $assembly.sam.log | /home/ajp/software/shrinksam-master/shrinksam > $assembly.sam

echo "calculating coverage..."
ruby 04_01calc_coverage_v3.rb -s $assembly.sam -f $assembly | sort -k1,1 > $assembly.scaff2cov.txt

echo "calculating GC content..."
ruby 04_02gc_count.rb -f $assembly | sort -k1,1 > $assembly.scaff2gc.txt

echo "parsing length of each scaffold..."
ruby 04_03fasta_length_individual.rb -f $assembly | sort -k1,1 > $assembly.scaff2len.txt

echo "cleaning up..."
rm $assembly.sam

echo "...done!"
