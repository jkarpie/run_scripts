#!/bin/bash
cfg=$1
stream=$2


here=`pwd`

ensemb="cl21_32_64_b6p3_m0p2350_m0p2050"

scratch=/qcd/volatile/JLabLQCD/jkarpie/
scratch_dir=${scratch}/redstar_run/$ensemb/${ensemb}-${stream}/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="redstar_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


pz_max=3

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o redstar_${cfg}
#SBATCH --job-name=${cfg}_red
#SBATCH -A hadstruc24s
#SBATCH --partition=24s
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --ntasks=8


source /etc/profile.d/modules.sh
module use /qcd/dist/el9/modulefiles
module load oneapi/2023.0.0.25537


module load mpi/openmpi-x86_64

export I_MPI_FABRICS=shm:ofi
export I_MPI_OFI_PROVIDER_DUMP=1
export I_MPI_OFI_PROVIDER=psm3

echo "Bopping"
${here}/run_bop.sh ${pz_max} ${cfg} 0.00 $stream 
echo "Bopped"

#for T in 0  
for T in 0 8 16 24 32 40 48 56 
do
${here}/run_npt.sh \$T ${pz_max} $cfg 0.00 $stream &
done
wait

EOF

sbatch ${filename}

popd
