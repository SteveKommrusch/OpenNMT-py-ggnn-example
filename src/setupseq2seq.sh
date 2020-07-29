#!/bin/bash

if [ ! -d $1 ]; then
    echo "Usage: setupseq2seq.sh dir"
    echo "       Creates raw data file from ANTLR *.txt results in directory 'dir'"
    echo "       Sets up OpenNMT files in runs/seq2seq"
    exit 0
fi
d=$1

for i in $d/*.txt; 
  do perl -pe 's/\s+/ /g; s/^/X /; chop' $i; 
  echo $i | perl -ne '/\/(\w+).txt/ && print " Y $1\n";'; 
done > raw_initial.txt

cd ../runs/seq2seq
perl -ne '/X (.*) Y/ && print "$1\n"' ../../data/raw_initial.txt > src-train.txt
perl -ne '/X (.*) Y/ && print "$1\n"' ../../data/raw_initial.txt > src-val.txt
perl -ne '/X (.*) Y/ && print "$1\n"' ../../data/raw_initial.txt > src-test.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/raw_initial.txt > tgt-train.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/raw_initial.txt > tgt-test.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/raw_initial.txt > tgt-val.txt

