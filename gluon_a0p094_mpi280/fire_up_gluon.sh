#!/bin/bash
cfg=$1
stream=$2


here=`pwd`

ensemb="cl21_32_64_b6p3_m0p2350_m0p2050"

scratch=/qcd/volatile/JLabLQCD/jkarpie/
scratch_dir=${scratch}/gluon_ops/${ensemb}_extension/${ensemb}-${stream}/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="gluon_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o gluon_${cfg}
#SBATCH --job-name=${cfg}_gluon
#SBATCH -A hadstruc24s
#SBATCH --partition=24s
#SBATCH -t 04:00:00
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --ntasks=4


source /etc/profile.d/modules.sh
module use /qcd/dist/el9/modulefiles


module load mpi/openmpi-x86_64

export I_MPI_FABRICS=shm:ofi
export I_MPI_OFI_PROVIDER_DUMP=1
export I_MPI_OFI_PROVIDER=psm3


${here}/run_gluon.sh $cfg $stream 

EOF

sbatch ${filename}

popd
