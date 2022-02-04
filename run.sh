#!/bin/bash
#
#$ -S /bin/bash
#$ -N X_EXPNAME_X
#$ -o _Y_TRAIN_Y_/X_EXPNAME_X/sge/out.sge
#$ -e _Y_TRAIN_Y_/X_EXPNAME_X/sge/err.sge
#$ -q long.q@*
#$ -l matylda3=0.1,gpu=_GPU_CNT_,gpu_ram=_GPU_RAM_G,mem_free=_MEM_FREE_G,ram_free=_RAM_FREE_G

expnam="X_EXPNAME_X"
gym=/mnt/matylda3/xskura01/workspace/gym
_train_file_=_PY_
_hyperparams_=_YAML_

# TODO: add custom environment
source /mnt/matylda3/xskura01/miniconda3/envs/activate_sb.sh || { 
  cat "ENV ERROR" >> $gym/"______$expnam""_______ERROR"
  echo "no conda env" ;
  exit 1 ;
}

# TODO: make compatible with custom train folder
cd _Y_TRAIN_Y_/$expnam || {
  cat "NO EXPNAM" >> $gym/"______$expnam""_______ERROR"
  echo "no tainfolder..." ; 
  exit 1 ;
}


##################################
python "${PWD}/$_train_file_" "${PWD}/$_hyperparams_" || { 
  # TODO cat log here
  touch $gym/"______$expnam""_______ERROR"
  exit 1 ;
}
##################################

# TODO: make email notification or something like this
cat $gym/$expnam/results/train_log.txt >>  $gym/"______$expnam""_______SUCCESS"



