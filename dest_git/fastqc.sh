#!usr/bin/bash

for i in $1*
do
	fastqc $i
done

