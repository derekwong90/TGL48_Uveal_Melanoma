##This script will extract the frequency of fragment lengths from a BAM file.

INPUTDIR='/cluster/projects/pughlab/external_data/TGL48_Uveal_Melanoma/bams_TS_CC/all_unique'
shdir='/cluster/projects/pughlab/projects/uveal_melanoma/insert_size/sh_scripts/all_unique'
outdir='/cluster/projects/pughlab/projects/uveal_melanoma/insert_size/output/all_unique'
picard_dir='/cluster/tools/software/picard/2.10.9'

mkdir -p $shdir
mkdir -p $outdir

cd $INPUTDIR
ls *Ct*.bam > bams
sed 's/....$//' bams > bam
rm bams
mv bam bams

for bam in $(cat bams); do
 cat << EOF > $shdir/${bam}_picard.sh
#!/bin/bash
#
module load picard

java -jar $picard_dir/picard.jar CollectInsertSizeMetrics \
I=$INPUTDIR/${bam}.bam \
O=$outdir/${bam}_picard.txt \
H=$outdir/${bam}.pdf \
VALIDATION_STRINGENCY=LENIENT \
M=0 \
W=320 

EOF

done

cd $shdir

ls *picard.sh > files
for file in $(cat files); do
sbatch -c 1 -t 2:00:00 -p all --mem 4G $file
done
