#!/usr/bin/bash



export OMP_NUM_THREADS=6
export OPENBLAS_NUM_THREADS=1
export MPICH_GPU_SUPPORT_ENABLED=1

export OMP_PLACES=threads
export OMP_PROC_BIND=spread

chromaform="/users/karpiejo/scratch/chromaform1"
. $chromaform/env.sh
. $chromaform/env_extra.sh
. $chromaform/env_extra_chroma.sh
. /users/karpiejo/run_scripts/2pts/env.sh


if [ $# -ne 1 ]; then
  echo "Usage: $0  <redstar xml input file>"
  exit 1
fi

f=$1

if [ ! -f $f ]; then
  echo "redstar input file does not exist: $f"
  exit 1
fi

/bin/rm -f hadron_node.xml

exe_red=${chromaform}/install/redstar-colorvec-hadron-hip-adat/bin/

$exe_red/redstar_corr_graph $f out.xml

status=$?
if [ $status != 0 ]; then
  echo "redstar_corr_graph failed"
  exit 1
fi

$exe_red/redstar_npt $f out.xml

status=$?
if [ $status != 0 ]; then
  echo "redstar_npt failed"
  exit 1
fi
