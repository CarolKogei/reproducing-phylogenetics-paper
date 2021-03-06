#!usr/bin/bash
module load samtools/1.9
module load minimap/2.2.22
module load htslib/1.9
module load bcftools/1.9

mkdir splits
mkdir markdups
mkdir plots
mkdir stats

for i in $1*
do
  	sample="$(basename -- $i)"
	mkdir splits/${sample%.fastq}
	split $i -l 4000000 splits/${sample%.fastq}/${sample%.fastq}
	mkdir markdups/${sample%.fastq}_marked

	for i in splits/${sample%.fastq}/*
	do
		name="$(basename -- $i)"
		minimap2 -t 32 -a -x sr consensus.fasta $i  | \
		samtools fixmate -m - - | \
		samtools sort -@32 -T /tmp/example_prefix - | \
		samtools markdup -r -@32 --reference consensus.fasta - markdups/${sample%.fastq}_marked/$name.bam
	done
	samtools merge ${sample%.fastq}_merged.bam markdups/${sample%.fastq}_marked/*
	samtools stats -c 1,1000,1 ${sample%.fastq}_merged.bam > ${sample%.fastq}_merged_stats
	#samtools coverage ${sample%.fastq}_merged.bam > ${sample%.fastq}_merged_coverage
	bcftools mpileup -d 1000 -SgB -Ou --threads 32  -f consensus.fasta ${sample%.fastq}_merged.bam | bcftools call --threads 32 -vmO z -o stats/${sample%.fastq}.vcf.gz
	tabix -p vcf stats/${sample%.fastq}.vcf.gz
	bcftools stats --threads 32 -F consensus.fasta -s - stats/${sample%.fastq}.vcf.gz > stats/${sample%.fastq}.vcf.gz.stats
	#plot-vcfstats -p plots/study.vcf.gz.stats
done

#bcftools filter --threads 32 -O z -o study_filtered.vcf.gz -s LOWQUAL -i'%QUAL>10' study.vcf.gz
