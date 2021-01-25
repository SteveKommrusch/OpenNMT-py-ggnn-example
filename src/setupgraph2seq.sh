#!/bin/bash

if [ ! -f ggnn.yaml ]; then
    echo "Usage: setupgraph2seq.sh "
    echo "       Initialize graph2seq data"
    echo "       Set up OpenNMT files in runs/graph2seq"
    exit 0
fi

cd ../../data
for i in antlr_files/*.txt; 
  do perl -pe 's/\s+/ /g; s/^/X /; chop' $i; 
  echo $i | perl -ne '/\/(\w+).txt/ && print " Y $1\n";'; 
done > raw_initial.txt
../src/raw2graph.pl < raw_initial.txt > graph_initial.txt

cd ../runs/graph2seq
perl -ne '/^\s*(.*) X .* Y/ && print "$1\n"' ../../data/graph_initial.txt > src-train.txt
perl -ne '/^\s*(.*) X .* Y/ && print "$1\n"' ../../data/graph_initial.txt > src-val.txt
perl -ne '/^\s*(.*) X .* Y/ && print "$1\n"' ../../data/graph_initial.txt > src-test.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/graph_initial.txt > tgt-train.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/graph_initial.txt > tgt-test.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/graph_initial.txt > tgt-val.txt

onmt_build_vocab -config ggnn.yaml -n_sample -1
mv srcvocab.txt rawsrcvocab.txt

# Note, change hard-coded 100 to grow the vocabulary as appropriate, 
# but this hardcoded vocab limit must be less than the GGNN node embedding size
# Note, change hard-coded 220 to grow maximum nodes in input graph
perl -e 'open($vocab,"<","rawsrcvocab.txt"); while (<$vocab>) { /^(\S+)/; $w=$1; if ($w=~/^\d+$/) {$nums{$w}=1; print "$w\n"; $n++} else {$w eq "," && ($comma=1); if ($w ne "<EOT>" && $n < 200) { print "$w\n"; $n++ } } }; $comma || print ",\n"; print "<EOT>\n"; for ($i=0; $i<220; $i++) { $nums{$i} || print "$i\n"}' > srcvocab.txt
