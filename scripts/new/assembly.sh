#!usr/bin/bash

fastq_files="$@"

flye --pacbio-raw $fastq_files -o out_pacbio -t 32
