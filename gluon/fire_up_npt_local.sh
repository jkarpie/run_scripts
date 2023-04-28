#!/bin/bash
cfg=$1
stream=$2


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
#SBATCH -o out_eig_${cfg}
#SBATCH --job-name=${cfg}_red
#SBATCH -A hadron
#SBATCH -q regular
#SBATCH -t 4:00:00
#SBATCH -N 1
#SBATCH -c 2
#SBATCH -C cpu
#SBATCH --ntasks-per-node=128

export SLURM_CPU_BIND="cores"
module load python

T=0
zeta=0



for pz in 0
do

${here}/npt.sh \$T 0 0 \$pz $cfg 0.00 $stream

done

EOF

sbatch ${filename}

popd
