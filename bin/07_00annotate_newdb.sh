if [ "$#" -lt 5 ]
then
   echo "usage: annotate.sh <protein_file> <scaffold_file> <dbdir> <threads> <script directory>"
 exit 1 
fi

proteins=$1
scaffolds=$2
dbdir=$3
threads=$4
dir=$5

diamond blastp -d $dbdir -q $proteins -o ${proteins}-vs-FunTaxDB.b6 -f 6 qseqid sseqid pident length qlen slen evalue bitscore salltitles -e 0.00001 -k 1 -p $threads 

ruby $dir/07_01classifier.rb -b ${proteins}-vs-FunTaxDB.b6 -s $scaffolds -g ${proteins} > $scaffolds.scaff2tax.txt
