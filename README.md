# OpenNMT-py-ggnn-example 

The top-level *txt files in this repository provide a quick example of how to use the gated graph neural network input for OpenNMT-py. Refer to the [ggnn.md](https://opennmt.net/OpenNMT-py/examples/GGNN.html) link for an example use of the files in the top-level directory.

# Graph input processing end-to-end example

The files in the 3 directories 'data', 'src', and 'runs' demonstrate how to use graph data represented textually with parenthesis with GGNN in OpenNMT (i.e., '(root (child1 2 3) (child2 4 5))'). Files in this format can be generated for various computer languages using [ANTLR4](https://www.antlr.org/).

### Step 1: Install OpenNMT-py and related packages
Install `OpenNMT-py` from `pip`:
```bash
pip install OpenNMT-py
```

or from the sources:
```bash
git clone https://github.com/OpenNMT/OpenNMT-py.git
cd OpenNMT-py
# The next step should be done on a CUDA-capable device
python setup.py install
```

Note: If you have MemoryError in the install try to use `pip` with `--no-cache-dir`.

*(Optional)* some advanced features (e.g. working audio, image or pretrained models) requires extra packages, you can install it with:
```bash
pip install -r requirements.opt.txt
```

### Step 2: Install ggnn-example and Environment setup
```bash
# cd to directory above OpenNMT-py
git clone git@github.com:SteveKommrusch/OpenNMT-py-ggnn-example.git
# Review env.sh script and adjust for your installation.
cd OpenNMT-py-ggnn-example
cat env.sh
source env.sh
```

### Step 3: Train and use GGNN model
```bash
cd runs/graph2seq
../../src/setupgraph2seq.sh
setsid nice -n 19 onmt_train --config ggnn.yaml < /dev/null > train.nohup.out 2>&1
onmt_translate -model model_step_10000.pt -src src-test.txt -output pred-test_beam10.txt -gpu 0 -replace_unk -beam_size 10 -n_best 10 -batch_size 4 -verbose > trans10.out 2>&1
python ../../src/compare.py --src=pred-test_beam10.txt --tgt=tgt-test.txt -v > pass10.txt
```

## Git file descriptions
 * data/antlr_files/*.txt: Output of [ANTLR4](https://www.antlr.org/) for 10 short programs in C++.
 * src/setupgraph2seq.sh: Creates vocab data and uses textual tree data to create OpenNMT GGNN input format.
 * src/raw2graph.pl: PERL script used by setupgraph2seq.sh to generate node, feature, and edge information for OpenNMT GGNN input format.
 * src/compare.py: Used to compare beam search translation output with expected target results. See steps above for example.
 * runs/graph2seq/ggnn.yaml: Commented parameters for GGNN run

## Key generated file descriptions
 * data/raw_initial.txt: 10 example programs generated using ANTLR. The format per lise is "X program Y target", where Y is the target output to be generated, in this case the algorithm's filename.
 * data/graph_initial.txt: 10 example programs in OpenNMT ggnn graph input format. The format per lise is "X program Y target", where Y is the target output to be generated, in this case the algorithm's filename. The program syntax is as per https://github.com/OpenNMT/OpenNMT-py/blob/master/docs/source/ggnn.md
 * runs/graph2seq/*vocab.txt: Files generated by setupgraph2seq.sh for use by graph neural network in OpenNMT. Note srcvocab.txt includes tokens for all node numbers to allow for proper edge connection setup for the model.

## Debugging issues
 * Some sample steps regarding setup and debug of the GGNN are discussed in OpenNMT-py issue 2058: https://github.com/OpenNMT/OpenNMT-py/issues/2058
