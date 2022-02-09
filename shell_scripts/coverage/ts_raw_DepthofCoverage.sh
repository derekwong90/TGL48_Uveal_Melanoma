INPUT=/cluster/projects/pughlab/external_data/TGL48_Uveal_Melanoma/TGL48_TS/bam
REF=/cluster/projects/pughlab/references/TGL/hg38/hg38_random.fa
output=/cluster/projects/pughlab/projects/uveal_melanoma/gatk_coverage/output/ts_raw
shdir=/cluster/projects/pughlab/projects/uveal_melanoma/gatk_coverage/sh_scripts/ts_raw
interval=/cluster/projects/pughlab/projects/uveal_melanoma/intervals/uveal_melanoma_hg38_liftover.bed

mkdir -p $output
mkdir -p $shdir

cd $INPUT
ls *.bam > $shdir/bams

cd $shdir
for bam in $(cat bams); do

echo -e "#!/bin/bash\n module load gatk/4.1.8.1\n" > $shdir/${bam}.sh
echo -e "gatk DepthOfCoverage\
 -R $REF\
 -O $output/$bam\
 -I $INPUT/$bam\
 -L $interval\
 --omit-interval-statistics true\
 --omit-locus-table true" >> $shdir/${bam}.sh 
done

cd $shdir

ls *.sh > files
for file in $(cat files);do

sbatch -c 1 -t 24:00:00 --mem 8G $file

done
