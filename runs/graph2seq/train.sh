#! /bin/bash


if [ ! -f $OpenNMT_py/preprocess.py ]; then
    print "OpenNMT_py environment variable should be set"
    exit 1
fi
if [ ! -d $data_path ]; then
    data_path=`/bin/pwd`
fi
cd $OpenNMT_py
# For full training, Change train_steps to 300000 and save_checkpoint_steps to 50000
python train.py -data $data_path/final -encoder_type ggnn -layers 2 -decoder_type rnn -rnn_size 256 -learning_rate 0.1 -start_decay_steps 15000 -learning_rate_decay 0.8 -global_attention general -batch_size 32 -word_vec_size 256 -bridge -train_steps 10000 -gpu_ranks 0 -save_checkpoint_steps 10000 -save_model $data_path/final-model -src_vocab $data_path/srcvocab.txt -n_edge_types 7 -state_dim 256 -n_steps 10 -n_node 220 > $data_path/train.final.out &
echo "train.sh complete" >> $data_path/train.out

