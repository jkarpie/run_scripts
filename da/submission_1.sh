#!/bin/bash
#SBATCH -o out
#SBATCH --job-name=da
#SBATCH -A hadron_g
#SBATCH -q regular
#SBATCH -t 2:00:00
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --ntasks-per-node=4
#SBATCH -C gpu --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"


. /global/cfs/cdirs/hadron/chromaform-perlmutter/env.sh
. /global/cfs/cdirs/hadron/chromaform-perlmutter/env_extra.sh
module load python

# Place to put new databases
mkdir -p  /global/cfs/cdirs/hadron/CLS_Nf2/E5/mes_2pt/1

#for k in 0 
#do
#for zeta in 0.0
#do 

#/global/homes/j/jkarpie/run_scripts/chroma_python/pseudo_da_cls.py #     -g "/global/cfs/cdirs/hadron/CLS_Nf2/E5/cfgs/64x32x32x32b5.30k0.13625c1.90952id9n" #     -k ${k} -z ${zeta} -c 1 -r 4.0 -p 8 #     -s "/global/cfs/cdirs/hadron/CLS_Nf2/E5/mes_2pt/" #     -w /global/homes/j/jkarpie/run_scripts/chroma_python/wfs/ > xml

/global/homes/j/jkarpie/run_scripts/chroma_python/pseudo_da_cls_bundle.py      -g "/global/cfs/cdirs/hadron/CLS_Nf2/E5/cfgs/64x32x32x32b5.30k0.13625c1.90952id9n"      -k 8 -c 1 -r 4.0 -p 8      -s "/global/cfs/cdirs/hadron/CLS_Nf2/E5/mes_2pt/"      -w /global/homes/j/jkarpie/run_scripts/chroma_python/wfs/ > xml

srun /global/cfs/cdirs/hadron/chromaform-perlmutter/install/chroma-quda-qdp-jit-double-nd4-cmake-superbblas-cuda/bin/chroma -i xml  -geom 1 1 1 4 -pool-max-alignment 512 -pool-max-alloc 0 

#done
#done
