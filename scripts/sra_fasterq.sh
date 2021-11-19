#!/usr/bin/bash

module load sratoolkit/2.11.3

for i in $(cat $1)
do
	fasterq-dump $i -t ./mugi -p
done
