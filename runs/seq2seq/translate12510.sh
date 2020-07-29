#! /bin/bash

if [ ! -f final-model_step_$1.pt ]; then
    echo "Usage: translate12510.sh modelnum"
    echo "       Creates 1,2,5,and 10 width beam outputs for final-model_step_[modelnum].pt"
    exit 0
fi
m=$1

mkdir -p m$m

hostname
data_path=`/bin/pwd`
cd $OpenNMT_py
python translate.py -model $data_path/final-model_step_$m.pt -src $data_path/src-test.txt -beam_size 1 -n_best 1 -gpu 0 -output $data_path/m$m/pred-test_beam1.txt -dynamic_dict 2>&1 > $data_path/m$m/translate1.out
python translate.py -model $data_path/final-model_step_$m.pt -src $data_path/src-test.txt -beam_size 2 -n_best 2 -gpu 0 -output $data_path/m$m/pred-test_beam2.txt -dynamic_dict 2>&1 > $data_path/m$m/translate2.out
python translate.py -model $data_path/final-model_step_$m.pt -src $data_path/src-test.txt -beam_size 5 -n_best 5 -gpu 0 -output $data_path/m$m/pred-test_beam5.txt -dynamic_dict 2>&1 > $data_path/m$m/translate5.out
python translate.py -model $data_path/final-model_step_$m.pt -src $data_path/src-test.txt -beam_size 10 -n_best 10 -gpu 0 -output $data_path/m$m/pred-test_beam10.txt -dynamic_dict 2>&1 > $data_path/m$m/translate10.out
