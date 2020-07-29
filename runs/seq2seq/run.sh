#! /bin/bash

hostname
data_path=`/bin/pwd`
preprocess.sh 2>&1 > preprocess.nohup.out
train.sh 2>&1 > train.nohup.out
