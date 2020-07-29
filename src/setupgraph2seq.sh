#!/bin/bash

if [ ! -f final.vocab.pt ]; then
    echo "Usage: setupgraph2seq.sh dir"
    echo "       Use final.vocab.pt to initialize graph2seq data"
    echo "       Sets up OpenNMT files in runs/graph2seq"
    exit 0
fi

echo -e "import torch\nv=torch.load('final.vocab.pt')\nv['src'].base_field.vocab.itos" | python -i > vocab.1line.txt

# Note, change hard-coded 100 to grow the vocabulary as appropriate, 
# but this hardcoded vocab limit must be less than the GGNN node embedding size
# Note, change hard-coded 220 to grow maximum nodes in input graph
perl -e 'open($vocab,"<","vocab.1line.txt"); $c=chr(39); $v=<$vocab>; while ($v=~s/^[^$c]*$c([^$c]*)$c//) {$w=$1; $n++; if ($w=~/^\d+$/) {$nums{$w}=1}; $w eq "," && ($comma=1); $n < 100 && print "$w\n"}; print "<EOT>\n"; $comma || print ",\n"; for ($i=0; $i<220; $i++) { $nums{$i} || print "$i\n"}' > ../graph2seq/srcvocab.txt

cd ../../data
../src/raw2graph.pl < raw_initial.txt > graph_initial.txt

cd ../runs/graph2seq
perl -ne '/^\s*(.*) X .* Y/ && print "$1\n"' ../../data/graph_initial.txt > src-train.txt
perl -ne '/^\s*(.*) X .* Y/ && print "$1\n"' ../../data/graph_initial.txt > src-val.txt
perl -ne '/^\s*(.*) X .* Y/ && print "$1\n"' ../../data/graph_initial.txt > src-test.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/graph_initial.txt > tgt-train.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/graph_initial.txt > tgt-test.txt
perl -ne '/Y (.*\S)\s*$/ && print "$1\n"' ../../data/graph_initial.txt > tgt-val.txt

# tgtvocab will just be the full set of possible 1-token results
sort -u tgt-train.txt > tgtvocab.txt
