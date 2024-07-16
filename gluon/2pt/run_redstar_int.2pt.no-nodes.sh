#!/usr/bin/bash


chromaform="/qcd/work/JLabLQCD/jkarpie/chromaform_24s/"
export OMP_NUM_THREADS=8

source /etc/profile.d/modules.sh
module use /qcd/dist/el9/modulefiles
module load oneapi/2023.0.0.25537
module load mpi/openmpi-x86_64
module list
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/w/22/JLabLQCD/jkarpie/chromaform_24s/install/openblas/lib"


export I_MPI_FABRICS=shm:ofi
export I_MPI_OFI_PROVIDER_DUMP=1
export I_MPI_OFI_PROVIDER=psm3


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

exe_red=${chromaform}/install/redstar-pdf-colorvec-pdf-hadron-cpu-adat-pdf-superbblas/bin/

#mpirun -np 1 --map-by ppr:1:node:PR=${OMP_NUM_THREADS} \
	$exe_red/redstar_corr_graph $f out.xml

#mpirun -np 1 --map-by ppr:1:node:PR=${OMP_NUM_THREADS} \
	$exe_red/redstar_npt $f out.xml


