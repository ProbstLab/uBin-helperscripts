if [ "$#" -lt 9 ]
then
   echo "usage: overview.sh <scaff2gc_file> <scaff2cov_file> <scaff2tax_file> <scaff2len_file> <scaffold_fasta> <faa> <dbdirectory> <searchengine> <threads>"
 exit 1 
fi

gc=$1
cov=$2
tax=$3
len=$4
sca=$5
pro=$6
dbdirectory=$7
engine=$8
threads=$9
ruby $dbdirectory/08_01astats.rb -g $gc -c $cov -t $tax -l $len -m 1000 > $sca.overview.txt

ruby $dbdirectory/08_02scg_metagenome.rb -s $sca -p $pro -d $dbdirectory -e $engine -t $threads
