#!/bin/bash
cfg=$1


here=`pwd`

chromaform="/users/karpiejo/scratch/chromaform2"
chroma="$chromaform/install/chroma-quda-qdp-jit-double-nd4-cmake/bin/chroma"

ensemb="cl21_64_192_b6p7_m0p1830_m0p1650"
beta="b6p7"

scratch=/users/karpiejo/scratch/
scratch_dir=${scratch}/qtop/$ensemb/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out
mkdir -p ${scratch_dir}/dbs

name_stem="qtop_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh

cfg_dir=${scratch}/${beta}/${ensemb}/cfgs/
pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_${cfg}
#SBATCH -e out_${cfg}
#SBATCH --job-name=qtop_${cfg}
#SBATCH -A project_465000563
#SBATCH -t 12:00:00
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

mkdir -p ${scratch_dir}/dbs/${cfg}


/users/karpiejo/run_scripts/gluon/make_qtop_xml.sh ${scratch_dir}/xml/${name_stem}.ini.xml ${cfg_dir}/${ensemb}_cfg_${cfg}.lime ${cfg}

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
