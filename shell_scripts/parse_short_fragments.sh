INPUTDIR=/cluster/projects/pughlab/external_data/TGL48_Uveal_Melanoma/TGL48_sWG/bam_deduplicated
outdir=/cluster/projects/pughlab/external_data/TGL48_Uveal_Melanoma/TGL48_sWG/bam_short
shdir=/cluster/projects/pughlab/projects/uveal_melanoma/parse_bams/sh_scripts

mkdir -p $outdir
mkdir -p $shdir

cd $INPUTDIR
ls *Ct*.bam > bams
sed 's/....$//' bams > bam
rm bams
mv bam bams

for bam in $(cat bams); do
 cat << EOF > $shdir/${bam}_short.sh
#!/bin/bash
#
module load samtools/1.10

samtools view -h $INPUTDIR/${bam}.bam | \
awk 'substr(\$0,1,1)=="@" || (\$9>= 90 && \$9<=150) || (\$9<=-90 && \$9>=-150)' | \
samtools view -b > $outdir/${bam}_short.bam

cd $outdir

samtools index ${bam}_short.bam

EOF

done 

cd $shdir

ls *_short.sh > files
for file in $(cat files);do
sbatch -c 1 -t 48:00:00 -p all --mem 8G $file

done
