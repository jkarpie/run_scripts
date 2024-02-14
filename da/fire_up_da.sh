#!/bin/bash
cfg=$1

here=`pwd`


scratch_dir="/users/karpiejo/scratch/CLS_Nf2/O7/da_runs/"
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


mkdir -p "/users/karpiejo/scratch/CLS_Nf2/O7/mes_2pt/${cfg}"

name_stem="da_bundle_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


chromaform="/users/karpiejo/scratch/chromaform1"
chroma="$chromaform/install/chroma-quda-qdp-jit-double-nd4-cmake/bin/chroma"

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_${cfg}
#SBATCH -e out_${cfg}
#SBATCH --job-name=da_${cfg}
#SBATCH -A project_465000563
#SBATCH -t 24:00:00
#SBATCH -p ju-standard-g
#SBATCH -N 8 -n64 --gpus-per-task=1 --gpu-bind=none



rm select_gpu
echo '#!/bin/bash' >> select_gpu
echo 'export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID '  >> select_gpu
echo 'exec \$* ' >> select_gpu


chmod +x select_gpu

CPU_BIND="mask_cpu:7e000000000000,7e00000000000000"
CPU_BIND="${CPU_BIND},7e0000,7e000000"
CPU_BIND="${CPU_BIND},7e,7e00"
CPU_BIND="${CPU_BIND},7e00000000,7e0000000000"




for rho in "2.0" "3.0" "4.0" "5.0" "6.0" "7.0"
do

/users/karpiejo/run_scripts/chroma_python/pseudo_da_cls_bundle.py \
     -e "O7" \
     -g "/users/karpiejo/scratch/CLS_Nf2/" \
     --ksourcemin 1 --ksourcemax 4  -c $cfg -r \${rho} -p 16 \
     -s "/users/karpiejo/scratch//CLS_Nf2/O7/mes_2pt/" \
     -w /users/karpiejo/run_scripts/chroma_python/wfs/ > ${scratch_dir}/xml/${name_stem}_r\${rho}.ini.xml




export OMP_NUM_THREADS=6
export OPENBLAS_NUM_THREADS=1
source ${chromaform}/env.sh
source ${chromaform}/env_extra.sh
source ${chromaform}/env_extra_chroma.sh
source ${here}/env.sh

export MPICH_GPU_SUPPORT_ENABLED=1

srun --cpu-bind=threads --threads-per-core=1 -c6 \
     ${chroma} \
     -geom 2 2 4 4  -poolsize 0k  -pool-max-alloc 0 -pool-max-alignment 512 \
     -i ${scratch_dir}/xml/${name_stem}_r\${rho}.ini.xml -o ${scratch_dir}/xml/${name_stem}_r\${rho}.out.xml 

done

EOF

sbatch ${filename}

popd
