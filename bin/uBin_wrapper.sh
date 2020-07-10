#!/bin/bash - 
#===============================================================================
#
#          FILE: uBin_input_preparer.sh
# 
#         USAGE: Type "bash uBin_input_preparer --help " for instructions
# 
#   DESCRIPTION: Script will prepare the uBin input starting from either 1) just the scaffold and read files or 2) will just collect the data into summaray files 
# 
#       OPTIONS: ---
#  REQUIREMENTS: assembly needs to be in fasta format and end on .fasta 
#                scaf2bin scaffoldIDs need to match to assembly
#                Installation
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 05/13/20 18:39
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


## edit modded cd to remove the -P flag
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
	  DIR="$( cd "$( dirname "$SOURCE" )" && pwd )"
	    SOURCE="$(readlink "$SOURCE")"
	      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
      done
      DIR="$( cd "$( dirname "$SOURCE" )" && pwd )"

      thisdir=$(pwd)

function display_version() {
  echo
  echo "uBin input preparer version 1.0"
  echo
  exit 1
}

uniref100=${DIR}/SCG/Uniref100_notax_and_tax_addedtogether_renewedDB.dmnd

function display_help() {
  echo " "
  echo "uBin input preparer version 1.0"
  echo " "
  echo "Usage: wrapper.sh -s scaffolds.fasta -p outputprefix [-r1 forread -r2 revread | -sr singleread ] -t threads -e usearch -db dbdir -b scaf2bin.tsv"
  echo "                -t threads -db dbdir"
  echo
  echo "   -s, --scaffolds            Scaffolds or Contigs in fasta format."
  echo "   -p, --prefix               Basename of output files."
  echo "   -r1, --read1               .fastq file with forward reads, can be .gz-zipped. Required if -sr isnt given."
  echo "   -r2, --read2               .fastq file with reverse reads, can be .gz-zipped. Required if -sr isnt given."
  echo "   -sr, --singleread          .fastq file with reverse reads, can be .gz-zipped. Required if -r1 and -r2 arent given."
  echo "   -e, --search_engine        Engine used for single copy gene identification [blast/diamond/usearch]."
  echo "                              (default: usearch)"
  echo "   -t, --threads              Number of threads to use. (default: 1)"
  echo "   -b, --scaf2bin             tab-separated file with scaffold IDs in the 1st and bins in the 2nd column. Optional"
  echo "   -v, --version              Print version number and exit."
  echo "   -h, --help                 Show this message."
  echo " "
  echo "   -g,--gatherfiles          Gather previously generated coverage,gc,length, taxonomy and scaffold information in an overview file and generate SCG data. "
  echo "                             Boolean: default: false"
  echo "   the following flags only work if -g true is set"
  echo "   -c,--coverage              scaffold2coverage table,tab-separated and no column name"
  echo "   -y,--gc                    scaffold2gc table,tab-separated and no column name"
  echo "   -l,--length                scaffold2length table,tab-separated and no column name"
  echo "   -x,--taxonomy              scaffold2taxonomy table,tab-separated and no column name"
  echo "   -f,--faa                   amino acid gene sequences file in fasta format. Is only required with -g true."
  exit 1
    }

    [ $# -eq 0 ] && { display_help ; exit 1; }

    binlabels="NULL"
    contigs="NULL"
    debug="FALSE"
    threads=1 
    search_engine="usearch"



while [ $# -gt 0 ]; do
    case $1 in 
	-s | --scaffolds )            shift
	                              scaffolds=$1
				      shift
         ;;
        -p | --prefix )               shift
                                      prefix=$1
				      shift
         ;;
        -r1 | --read1 )               shift
                                      read1=$1
				      shift
         ;;
        -r2 | --read2 )               shift
                                      read2=$1
				      shift
         ;;
        -sr | --singleread )          shift
                                      single_read=$1
				      shift
         ;;
        -t | --threads )              shift
                                      threads=$1
				      shift
         ;;
        -e | --search_engine )        shift
	                              search_engine=$1
				      shift
         ;;
        -b | --scaf2bin )             shift
                                      scaf2bin=$1
				      shift
         ;;
	-g | --gatherfiles )          shift
                                      gatherfiles=$1
                                      shift
         ;;
	-c | --coverage )             shift
                                      cov=$1
                                      shift
         ;;
	-y | --gc )                   shift
                                      gc=$1 
                                      shift
         ;;
	-x | --taxonomy)              shift
                                      taxonomy=$1
                                      shift
         ;;
	-l | --length )               shift
                                      len=$1
                                      shift
         ;;
	-f | --faa )                 shift
		                     faa=$1
			             shift
        ;;
        -v | --version )              display_version
		                      echo "version"
                                      exit
         ;;
        -h | --help )                 display_help
		                      echo "help"
                                      exit
         ;;
        * )                           display_help
                                      echo 'other' 
		                      exit
	 ;;
        esac 

done
#check search engine
if [ "$search_engine" == "diamond" ] || [ "$search_engine" == "DIAMOND" ] || [ "$search_engine" == "Diamond" ] || [ "$search_engine" == "d" ] || [ "$search_engine" == "D" ]; then
	command -v diamond >/dev/null 2>&1 || { echo >&2 "Can't find diamond. Please make sure DIAMOND is installed on your system. Aborting."; exit 1; }
	search_engine="diamond"
fi
if [ "$search_engine" == "blast" ] ||  [ "$search_engine" == "BLAST" ] || [ "$search_engine" == "Blast" ] || [ "$search_engine" == "b" ] || [ "$search_engine" == "B" ] || [ "$search_engine" == "blastp" ]; then
	command -v makeblastdb >/dev/null 2>&1 || { echo >&2 "Can't find makeblastdb. Please make sure BLAST is installed on your system.  Aborting."; exit 1; }
	command -v blastp >/dev/null 2>&1 || { echo >&2 "Can't find blastp. Please make sure BLAST is installed on your system. Aborting."; exit 1; }
	search_engine="blast"
fi
if [ "$search_engine" == "usearch" ] || [ "$search_engine" == "USEARCH" ] || [ "$search_engine" == "UBLAST" ] || [ "$search_engine" == "Usearch" ] || [ "$search_engine" == "u" ] || [ "$search_engine" == "U" ] || [ "$search_engine" == "ublast" ] || [ "$search_engine" == "Ublast" ]; then
	command -v usearch >/dev/null 2>&1 || { echo >&2 "Can't find usearch. Please make sure USEARCH is installed on your system. Aborting."; exit 1; }
	search_engine="usearch"
fi








min1000=$(echo ${prefix}_min1000.fasta)

if [ -z ${gatherfiles+x} ]; then
	echo "all files will get generated from scratch"
else
    bash ${DIR}/08_00overview.sh $gc $cov $taxonomy $len $min1000 $faa $DIR $search_engine $threads
    if [ -z ${scaf2bin+x} ];then
        echo "no scaf2binfile was supplied"
        else
		min1000=$(echo $faa | sed "s/\.genes\.faa//")
                bash ${DIR}/09_additionbincol.sh $scaf2bin $min1000.overview.txt > $min1000.overview_bincol.txt
        fi
    exit 1
fi


bash ${DIR}/03_format_assembly.sh $scaffolds $prefix
#mapping
if [ -z ${single_read+x} ];then
	bash ${DIR}/04_00map_mod.sh $scaffolds $read1 $read2 $threads
else
	bash ${DIR}/04_map_SR.sh $scaffolds $single_read $threads
fi
# define output file names generated in the previous mapping
cov=$(echo $scaffolds | sed "s/$/.scaff2cov.txt/")
gc=$(echo $scaffolds | sed "s/$/.scaff2gc.txt/")
len=$(echo $scaffolds | sed "s/$/.scaff2len.txt/")

#ORF prediction
bash ${DIR}/06_MPfast_mod.sh $min1000 $threads
faa=$(echo $min1000 | sed "s/fasta$/genes.faa/")

## uniref100 annotation
bash ${DIR}/07_00annotate_newdb.sh $faa $min1000 $uniref100 $threads
tax=$(echo $min1000 | sed "s/$/.scaff2tax.txt/")

#overview table and SCG identification, variable search engines
bash ${DIR}/08_00overview.sh $gc $cov $tax $len $min1000 $faa $DIR $search_engine $threads 

#optional scaf2binfile
if [ -z ${scaf2bin+x} ];then
	echo "no scaf2binfile was supplied and thus no Bin column was added to the overview table."
	else
		bash ${DIR}/09_additionbincol.sh $scaf2bin $min1000.overview.txt > $min1000.overview_bincol.txt
	fi
