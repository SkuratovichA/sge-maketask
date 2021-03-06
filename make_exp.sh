#!/bin/bash

OWNER=$(whoami)

# TODO: somehow add envnam to script
ENVNAM=sb

name=$(python -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')
py="train.py"
yaml="train.yaml"
RUN_SCRIPT="/mnt/matylda3/$OWNER/workspace/scripts/run.sh"
gpu="1"
gpu_ram="40"
mem_free="10"
ram_free="16"
yaml="train.yaml"
py="train.py"
add=""
traindir="/mnt/matylda3/$OWNER/workspace/gym"
run=0
qsub=1


source "/mnt/matylda3/$OWNER/miniconda3/envs/activate_$ENVNAM.sh" || { "No conda environment" ; exit ; }
# if [[ "$full_hostname" == *fit.vutbr.[cC][zZ] ]]; then
#   source "/mnt/matylda3/$OWNER/miniconda3/envs/activate_$ENVNAM.sh" || { "No conda environment" ; exit ; }
#   echo "SGE will be used"
# fi
# 
# if [[ "$full_hostname" == *it4i.cz ]]; then
#   echo "notImplemented"
#   exit 0
#   source "/mnt/matylda3/$OWNER/miniconda3/envs/activate_$ENVNAM.sh" || { "No conda environment" ; exit ; }
# fi

# conf_params=""

# . ../rustyspoons/utils/parse_options.sh
print_help() {
  echo "--name             => experimet and directory name. default: unix timestamp, e.g. ${name}"
  echo "--run              => submitting a task. default: ${run}"
  echo "--qsub             => use qsub or bash for running (if run is 1). default: ${qsub}"
  echo "--add              => additional files for training. TODO: ONLY ONE FILE IS SUPPORTED, YET"
  echo "--traindir         => directory. defaut: ${traindir}"
  echo "--gpu              => number of gpus. default: ${gpu}"
  echo "--gpu_ram          => gpu ram. default: ${gpu_ram}G"
  echo "--mem_free         => ???. default: ${mem_free}G"
  echo "--ram_free         => ???. default: ${ram_free}G"
  echo "--yaml             => hyperparams file. default: $yaml"
  echo "--py               => python file. default: $py"
}

print_params() {
  echo "Params:"
  echo "  --name               = $name      " 
  echo "  --run                = $run       "  
  echo "  --qsub               = $qsub      "  
  echo "  --add                = $add       " 
  echo "  --traindir           = $traindir  "
  echo "  --gpu                = $gpu       "  
  echo "  --gpu_ram            = $gpu_ram   "  
  echo "  --mem_free           = $mem_free  "  
  echo "  --ram_free           = $ram_free  "  
  echo "  --yaml               = $yaml      "  
  echo "  --py                 = $py        "  
}

# if [[ "$#" -eq 0 ]] ; then
#   print_help
#   exit -1
# fi
while [ "$#" -gt 0 ] ; do
  case "$1" in
    --name)
      shift
      name="$1"
      ;;
    --traindir)
      shift
      traindir="$1"
      echo "Not supported yet"
      exit 1
      ;;
    --run)
      run=1
      ;;
    --qsub|--clusterfuck)
      qsub=1
      ;;
    --py)
      shift
      py="$1"
      ;;
    --yaml)
      shift
      yaml="$1"
      ;;
    --add)
      shift
      add="$add $1"
      ;;
    --gpu)
      shift
      gpu="$1"
      ;;
    --gpu_ram)
      shift
      gpu_ram="$1"
      ;;
    --mem_free)
      shift
      mem_free="$1"
      ;;
    --ram_free)
      shift
      ram_free="$1"
      ;;
    *)
      echo "Argument: \"$1\""
      print_help
      exit 1
      ;;
    ## TODO: envname, owner...
  esac
  shift
done

print_params


if [  "$traindir" = "" ] ; then
  echo "Set the traindir parameter properly !"
  exit 1
fi
if [  "$name" = "" ] ; then
  echo "Set the name parameter properly !"
  exit 1
fi
mkdir -p "$traindir"

# check directory
if [ -d "$traindir/$name" ]; then
  echo -n "Experiment \"$traindir/$name\" exists. Overwrite? [y/n]: "
  read -r ans
  if [[ "$ans" == [Nn] ]]; then
    echo "Aborting..."
    exit 0
  fi
fi
mkdir -p "$traindir/${name}"


# change this mess
sed '
	s|X_EXPNAME_X|'${name}'|g;
	' $RUN_SCRIPT > "$traindir/${name}/run.sh" 

sed -i "s|_Y_TRAIN_Y_|${traindir}|g" "$traindir/${name}/run.sh"
sed -i "s|_PY_|${py}|g"              "$traindir/${name}/run.sh"
sed -i "s|_YAML_|${yaml}|g"          "$traindir/${name}/run.sh"
sed -i "s|_GPU_CNT_|${gpu}|g"        "$traindir/${name}/run.sh"
sed -i "s|_GPU_RAM_|${gpu_ram}|g"    "$traindir/${name}/run.sh"
sed -i "s|_MEM_FREE_|${mem_free}|g"  "$traindir/${name}/run.sh"
sed -i "s|_RAM_FREE_|${ram_free}|g"  "$traindir/${name}/run.sh"
#^^
 

#  TODO: make it possible to use more additional files than only one
if [[ "$add" = "" ]]; then
  cp "$py" "$yaml" "$traindir/${name}/"
else
  cp $add "$py" "$yaml" "$traindir/${name}/"
fi

# folder for sge reports
mkdir -p "$traindir/${name}/sge"

if [ ${run} -eq 1 ]; then
  if [ ${qsub} -eq 1 ]; then
    qsub "$traindir/${name}/run.sh"
  else
    bash "$traindir/${name}/run.sh"
  fi
fi

echo ""
echo "new task $traindir/${name} created"
