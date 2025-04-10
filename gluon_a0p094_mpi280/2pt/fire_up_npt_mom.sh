#!/bin/bash
T=$1
cfg=$2
stream=$3
px=$4
py=$5
pz=$6

here=`pwd`

ensemb="cl21_32_64_b6p3_m0p2350_m0p2050"

scratch=/pscratch/sd/j/jkarpie
scratch_dir=${scratch}/redstar_run/$ensemb/${ensemb}-${stream}/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="redstar_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o redstar_${cfg}_T${T}_p${px}.${py}.${pz}
#SBATCH --job-name=${cfg}_red
#SBATCH -A hadron
#SBATCH -q regular
#SBATCH -t 2:00:00
#SBATCH -N 1
#SBATCH -c 2
#SBATCH -C cpu
#SBATCH --ntasks-per-node=128

export SLURM_CPU_BIND="cores"
module load python

zeta=0



${here}/npt.sh $T $px $py $pz $cfg 0.00 $stream


EOF

sbatch ${filename}

popd
