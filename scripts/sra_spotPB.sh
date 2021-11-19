#!/bin/bash
module load  sratoolkit/2.11.3

for i in `cat $1`
do
  	fastq-dump -I --split-spot --skip-technical $i
done
