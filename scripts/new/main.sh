#!usr/bin/bash

module load sratoolkit/2.11.3

#first commandline argument assigned to a variable 
#This argument is the file containing a list of accession numbers with a new line as a delimitor
accession_list="$1"

mkdir sra_files
mkdir fastq_files
mkdir fastqc_files

prefetch -f yes -O sra_files --option-file $accession_list

fasterq-dump -s --skip-technical -e 32 -O fastq_files sra_files/*/*.sra

fastqc -o fastqc_files fastq_files/*

module load sratoolkit/2.11.3

#first commandline argument assigned to a variable 
#This argument is the file containing a list of accession numbers with a new line as a delimitor
#accession_list="$1"

#mkdir sra_files
mkdir fastq_files
mkdir fastqc_files

prefetch -f yes -O sra_files --option-file $accession_list


fastq-dump -I --split-spot --skip-technical -O fastq_files sra_files/*/*.sra

fastqc -o fastqc_files fastq_files/*

#!usr/bin/bash

fastq_files="$@"

flye --pacbio-raw $fastq_files -o out_pacbio -t 32
