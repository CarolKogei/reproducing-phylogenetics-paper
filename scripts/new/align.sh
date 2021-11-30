#!usr/bin/bash
module load samtools/1.14
module load minimap/2.2.22
module load bcftools/1.14


if [[ ! -e "splits" ]]
then
	mkdir splits
fi

if [[ ! -e "markdups" ]]
then
	mkdir markdups
fi

mkdir stats coverage vcf_files pseudogenes plots

#folder containing the sample file to be aligned to the
#reference genome
sample_files="$1*"

consensus="$2"

for i in $sample_files
do
  	sample="$(basename -- $i)"
	mkdir splits/${sample%.fastq}
	split $i -l 4000000 splits/${sample%.fastq}/${sample%.fastq}
	mkdir markdups/${sample%.fastq}

	for i in splits/${sample%.fastq}/*
	do
		name="$(basename -- $i)"
		minimap2 -t 32 -a -x sr $consensus $i  | \
		samtools fixmate -m - - | \
		samtools sort -@32 -T /tmp/example_prefix - | \
		samtools markdup -r -@32 --reference $consensus - markdups/${sample%.fastq}/$name.bam
	done
	samtools merge ${sample%.fastq}.bam markdups/${sample%.fastq}/*
	samtools stats -c 1,1000,1 ${sample%.fastq}.bam > stats/${sample%.fastq}_stats
	samtools coverage ${sample%.fastq}.bam > coverage/${sample%.fastq}_coverage

	bcftools mpileup -d 1000 -SgB -Ou --threads 32  -f $consensus ${sample%.fastq}.bam | bcftools call --threads 32 -vmO z -o vcf_files/${sample%.fastq}.vcf.gz

	tabix -p vcf vcf_files/${sample%.fastq}.vcf.gz
	bcftools stats --threads 32 -F $consensus -s - vcf_files/${sample%.fastq}.vcf.gz >vcf_files/${sample%.fastq}.vcf.gz.stats
	#plot-vcfstats -p plots/${sample%.fastq}.vcf.gz.stats vcf_files/${sample%.fastq}.vcf.gz.stats

	#bcftools filter --threads 32 -O z -o vcf_files/${sample%.fastq}_filtered.vcf.gz -s LOWQUAL -i'%QUAL>30' vcf_files/${sample%.fastq}.vcf.gz	

	# normalize indels
	#bcftools norm -f $consensus vcf_files/${sample%.fastq}.vcf.gz -Ob -o vcf_files/${sample%.fastq}.norm.bcf

	# filter adjacent indels within 5bp
	#bcftools filter --IndelGap 5 vcf_files/${sample%.fastq}.norm.bcf -Ob -o vcf_files/${sample%.fastq}.norm.flt-indels.bcf

	# apply variants to create consensus sequence
	#cat $consensus | bcftools consensus vcf_files/${sample%.fastq}.vcf.gz > pseudogenes/${sample%.fastq}.fasta

done
