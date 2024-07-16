#!/bin/bash

pz_max=$1
cfg=$2
phase=$3
stream=$4

echo "Bopping along"
source /etc/profile.d/modules.sh
module use /qcd/dist/el9/modulefiles
module load oneapi/2023.0.0.25537
module load mpi/openmpi-x86_64
module list

export I_MPI_FABRICS=shm:ofi
export I_MPI_OFI_PROVIDER_DUMP=1
export I_MPI_OFI_PROVIDER=psm3

export OMP_NUM_THREADS=8

export ENSEM=cl21_32_64_b6p3_m0p2350_m0p2050
export BETA=b6p3
#PROJ IS LOCATION OF INPUT DATA
export PROJ=/qcd/cache/isoClover/${ENSEM}_extension/${ENSEM}-${stream}/

cfg_file=${PROJ}/cfgs/${ENSEM}-${stream}_cfg_${cfg}.lime
eig_file=${PROJ}/eig/${ENSEM}-${stream}_eigen_z0_light.${cfg}.eig

chromaform="/qcd/work/JLabLQCD/jkarpie/chromaform_24s"
chroma_dir="${chromaform}/install/chroma-restructure-mgproto-qphix-qdpxx-double-nd4-avx512-superbblas-cpu/"
CHROMA="${chroma_dir}/bin/chroma"
CHROMA_EX="-by 4 -bz 4 -pxy 0 -pxyz 0 -c $OMP_NUM_THREADS -sy 1 -sz 1 -minct 1"
GEOM="-geom 1 1 1 8"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/w/22/JLabLQCD/jkarpie/chromaform_24s/install/openblas/lib"




name_stem="baryon_${cfg}"

#source ${chromaform}/env.sh

scratch=/qcd/volatile/JLabLQCD/jkarpie/
scratch_dir=${scratch}/baryon_ops/${ENSEM}_extension/${ENSEM}-${stream}/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out
mkdir -p ${scratch_dir}/dbs

output_dir=/scratch/JLabLQCD/jkarpie/baryon_ops/${ENSEM}_extension/${ENSEM}-${stream}
mkdir -p ${output_dir}/dbs/${cfg}

export OPENBLAS_NUM_THREADS=1

/qcd/work/JLabLQCD/jkarpie/run_scripts_24s/gluon/2pt/make_bop_xml.sh \
	${scratch_dir}/xml/${name_stem}.ini.xml \
	${pz_max} \
	${phase} \
	${eig_file} \
	${cfg_file} \
	${output_dir}/dbs/${cfg}/${ENSEM}-$stream.n64.t0_0.NtFwd_64.baryon.colorvec

mpirun -np 8 \
	--map-by ppr:8:node:PE=${OMP_NUM_THREADS}  \
  $CHROMA $CHROMA_EX $GEOM \
  -i ${scratch_dir}/xml/${name_stem}.ini.xml -o ${scratch_dir}/xml/${name_stem}.out.xml >${scratch_dir}/out/${name_stem}.out 


