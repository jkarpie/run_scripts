#!/usr/bin/bash



export OMP_NUM_THREADS=128
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export MKL_NUM_THREADS=1

chromaform="/global/cfs/projectdirs/hadron/chromaform-perlmutter"

. $chromaform/env.sh
. $chromaform/env_extra.sh


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

exe_red=${chromaform}/install/redstar-pdf-colorvec-pdf-hadron-cuda-adat-pdf-superbblas/bin/

$exe_red/redstar_corr_graph $f out.xml
if [ $status != 0 ]; then
  echo "redstar_corr_graph failed"
  exit 1
fi

$exe_red/redstar_npt $f out.xml
if [ $status != 0 ]; then
  echo "redstar_npt failed"
  exit 1
fi
