#!/bin/bash
cfg=$1


here=`pwd`

chromaform="/pfs/lustrep4/scratch/project_465000563/chromaform_eloy/"
chroma="${chromaform}/install/chroma-restructure-qdp-jit-double-nd4-cmake/bin/chroma"


ensemb="cl21_32_64_b6p3_m0p2350_m0p2050"

scratch=/users/karpiejo/scratch/
scratch_dir=${scratch}/gluon_ops/$ensemb/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out
mkdir -p ${scratch_dir}/dbs

name_stem="gluon_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh

cfg_dir=${scratch}/b6p3/${ensemb}/cfgs/
pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_${cfg}
#SBATCH -e out_${cfg}
#SBATCH --job-name=gluon_${cfg}
#SBATCH -A project_465000563
#SBATCH -t 00:20:00
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
source ${chromaform}/env_extra0.sh  
source ${chromaform}/env_extra_res.sh  
source ${chromaform}/env_extra.sh
source ${chromaform}/env.sh


source ~/run_scripts/2pts/env.sh


export MPICH_GPU_SUPPORT_ENABLED=1

mkdir -p ${scratch_dir}/dbs/${cfg}
/users/karpiejo/run_scripts/chroma_python/gpdf.py \
     -g "${cfg_dir}/${ensemb}_cfg" \
     -c $cfg  \
     -s "${scratch_dir}/dbs/"  > ${scratch_dir}/xml/${name_stem}.ini.xml




export OMP_NUM_THREADS=6
export OPENBLAS_NUM_THREADS=1
source ${chromaform}/env.sh
source ${chromaform}/env_extra.sh
source ${chromaform}/env_extra_chroma.sh
source ${here}/env.sh

export MPICH_GPU_SUPPORT_ENABLED=1

srun --cpu-bind=threads --threads-per-core=1 -c6 \
     ${chroma} \
     -geom 1 1 2 4  -poolsize 0k  -pool-max-alloc 0 -pool-max-alignment 512 \
     -i ${scratch_dir}/xml/${name_stem}.ini.xml -o ${scratch_dir}/xml/${name_stem}.out.xml



EOF

sbatch ${filename}

popd
