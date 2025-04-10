#!/bin/bash
T=$1
cfg=$2


here=`pwd`

ensemb="cl21_32_64_b6p3_m0p2390_m0p2050"

scratch=/pscratch/sd/j/jkarpie
scratch_dir=${scratch}/redstar_run/$ensemb/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="redstar_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o redstar_${cfg}_T${T}
#SBATCH --job-name=${cfg}_red
#SBATCH -A hadron_g
#SBATCH -q regular
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --ntasks-per-node=4
#SBATCH -C gpu --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"

export QUDA_ENABLE_GDR=0



module load python

zeta=0



${here}/npt_generator.sh $T 0 0 0 $cfg 0.00
${here}/npt_generator.sh $T 0 1 0 $cfg 0.00
${here}/npt_generator.sh $T 0 -1 0 $cfg 0.00
${here}/npt_generator.sh $T 1 0 0 $cfg 0.00
${here}/npt_generator.sh $T -1 0 0 $cfg 0.00

for pz in {1..3}
do

${here}/npt_generator.sh $T 0 0 \$pz $cfg 0.00
${here}/npt_generator.sh $T 0 0 -\$pz $cfg 0.00
${here}/npt_generator.sh $T 0 1 \$pz $cfg 0.00
${here}/npt_generator.sh $T 0 -1 -\$pz $cfg 0.00
${here}/npt_generator.sh $T 1 0 \$pz $cfg 0.00
${here}/npt_generator.sh $T -1 0 -\$pz $cfg 0.00

done # for pz


EOF

sbatch ${filename}

popd
