#! /bin/bash

export CUDA_VISIBLE_DEVICES=0
export THC_CACHING_ALLOCATOR=0
export OpenNMT_py=`dirname $PWD`/OpenNMT-py
export data_path=`dirname $PWD`/OpenNMT-py-ggnn-example
