#!/bin/bash
module load  sratoolkit/2.11.3

for i in `cat pacbio.txt`
do
  	fastq-dump -I --split-spot --skip-technical $i
done
