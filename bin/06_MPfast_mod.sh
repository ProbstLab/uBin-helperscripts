if [ "$#" -lt 1 ]
then
   	echo "runs prodigal in meta mode with the specified number of threads in parallel."
	echo "usage: mp_fast.sh <scaffold_file>"
 exit 1
fi

fasta=$1
threads=$2
lines=$(( $(grep -c ">" $fasta) / $threads ))

grep ">" $fasta | sed "s/>//g" > headers.tmp

split -l $lines headers.tmp batch.

for batch in $(ls -1 batch.*); do
  pullseq -i $fasta -n $batch > $batch.fasta
  prodigal -q -i $batch.fasta -a $batch.fasta.genes.faa -o $batch.fasta.genes -d $batch.fasta.genes.fna -m -p meta &
done
wait

basename=$(echo $fasta | sed "s/\.fasta//g")
cat batch.*.genes.faa > $basename.genes.faa
cat batch.*.genes.fna > $basename.genes.fna
cat batch.*.genes > $basename.genes

rm batch.* headers.tmp
