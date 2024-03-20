#!/bin/bash
cfg=$1


here=`pwd`

ensemb="cl21_32_64_b6p3_m0p2350_m0p2050"

scratch=/users/karpiejo/scratch/
scratch_dir=${scratch}/redstar_run/$ensemb/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="redstar_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_${cfg}
#SBATCH -e out_${cfg}
#SBATCH --job-name=nuc2pt_${cfg}
#SBATCH -A project_465000563
#SBATCH -t 24:00:00
#SBATCH -p ju-standard-g
#SBATCH -N 1 -n8 --gpus-per-task=1 --gpu-bind=none



rm select_gpu
echo '#!/bin/bash' >> select_gpu
echo 'export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID '  >> select_gpu
echo 'exec \$* ' >> select_gpu


chmod +x select_gpu

CPU_BIND="mask_cpu:7e000000000000,7e00000000000000"
CPU_BIND="${CPU_BIND},7e0000,7e000000"
CPU_BIND="${CPU_BIND},7e,7e00"
CPU_BIND="${CPU_BIND},7e00000000,7e0000000000"



export OMP_NUM_THREADS=6
export OPENBLAS_NUM_THREADS=1
source ${chromaform}/env.sh
source ${chromaform}/env_extra.sh
source ${chromaform}/env_extra_chroma.sh
source ~/run_scripts/2pts/env.sh


export MPICH_GPU_SUPPORT_ENABLED=1

zeta=0

for T in 0 16 32 48 
do

for pz in 0
do

${here}/npt_local.sh \$T 0 0 \$pz $cfg 0.00 

done
done

EOF

sbatch ${filename}

popd
