#!/bin/sh
# echo list of nodes to job output
# useful to rsh into nodes while job is running to run top/nvidia-smi
jsrun -r 1 /bin/hostname

# Chaining bsub requests
# see chainer.sh for what the arguments are
sh chainer_ddp.sh $1 $2 &

echo "START"

echo `which python`

# Go to training dir (specified by chainer.sh)
cd $TRAINDIR
echo TRAINDIR
echo `pwd`

# set MASTER_ADDR to hostname of first compute node in allocation
# set MASTER_PORT to any used port number
# get hostname of node that jsrun considers to be first (where rank 0 will run)
# export MASTER_ADDR=`cat $LSB_DJOB_HOSTFILE | head -2 | tail -1`
firsthost=`jsrun --nrs 1 -r 1 /bin/hostname`
export MASTER_ADDR=$firsthost
export MASTER_PORT=12321
export NUM_PROCESS_PER_NODE=4

echo "jsrun --smpiargs="-disable_gpu_hooks" -r $NUM_PROCESS_PER_NODE python $TRAINSCRIPT --config_file $TRAINCONFIG"
jsrun --smpiargs="-disable_gpu_hooks" -r $NUM_PROCESS_PER_NODE python $TRAINSCRIPT --config_file $TRAINCONFIG

echo "END"