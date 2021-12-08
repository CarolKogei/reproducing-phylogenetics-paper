#!usr/bin/bash

module load sratoolkit/2.11.3

#first commandline argument assigned to a variable 
#This argument is the file containing a list of accession numbers with a new line as a delimitor
accession_list="$1"

#creates three folders within which relevant documents will be contained
mkdir sra_files fastq_files fastqc_files

#prefetch from sra to save on computation resources
prefetch -f yes -O sra_files --option-file $accession_list

#extracts the fastq files from the sra prefetch files and split spots into reads using 32 threads
fasterq-dump -s --skip-technical -e 32 -O fastq_files sra_files/*/*.sra

#run quality checks with fastqc
fastqc -o fastqc_files fastq_files/*

