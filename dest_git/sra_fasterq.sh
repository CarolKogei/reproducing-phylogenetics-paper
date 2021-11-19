#!/usr/bin/bash

module load sratoolkit/2.11.3

for i in $(cat pacbio.txt)
do
	fasterq-dump $i -t ./mugi -p
done
