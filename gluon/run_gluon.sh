#!/bin/bash

cfg=$1
stream=$2


source /etc/profile.d/modules.sh
module use /qcd/dist/el9/modulefiles
module load mpi/openmpi-x86_64
module list

export I_MPI_FABRICS=shm:ofi
export I_MPI_OFI_PROVIDER_DUMP=1
export I_MPI_OFI_PROVIDER=psm3

export OMP_NUM_THREADS=16

export ENSEM=cl21_32_64_b6p3_m0p2350_m0p2050
export BETA=b6p3
#PROJ IS LOCATION OF INPUT DATA
export PROJ=/qcd/cache/isoClover/${ENSEM}_extension/${ENSEM}-${stream}/

cfg_dir=${PROJ}/cfgs/


chromaform="/qcd/work/JLabLQCD/jkarpie/chromaform_24s"
chroma_dir="${chromaform}/install/chroma-restructure-qdpxx-double-nd4-superbblas-cpu/"
CHROMA="${chroma_dir}/bin/chroma"
CHROMA_EX="-by 4 -bz 4 -pxy 0 -pxyz 0 -c $OMP_NUM_THREADS -sy 1 -sz 1 -minct 1"
GEOM="-geom 1 1 1 4"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/w/22/JLabLQCD/jkarpie/chromaform_24s/install/openblas/lib"




name_stem="gluon_${cfg}"

#source ${chromaform}/env.sh

scratch=/qcd/volatile/JLabLQCD/jkarpie/
scratch_dir=${scratch}/gluon_ops/${ENSEM}_extension/${ENSEM}-${stream}/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out
mkdir -p ${scratch_dir}/dbs

output_dbs=/qcd/work/JLabLQCD/jkarpie/gluon_ops/${ENSEM}_extension/${ENSEM}-${stream}/
mkdir -p ${output_dbs}/dbs/$cfg
/qcd/work/JLabLQCD/jkarpie/run_scripts_24s/chroma_python/gpdf.py \
     -g "${cfg_dir}/${ENSEM}-${stream}_cfg" \
     -c $cfg  \
     -s "${output_dbs}/dbs/"  > ${scratch_dir}/xml/${name_stem}.ini.xml

mpirun -np 4 \
	--map-by ppr:4:node:PE=${OMP_NUM_THREADS}  \
  $CHROMA $CHROMA_EX $GEOM \
  -i ${scratch_dir}/xml/${name_stem}.ini.xml -o ${scratch_dir}/xml/${name_stem}.out.xml


