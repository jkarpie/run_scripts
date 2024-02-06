#!/bin/bash
#SBATCH -A project_465000525
#SBATCH -J tst
#SBATCH -o t0.out
#SBATCH -t 0:10:00
#SBATCH -p standard-g
#SBATCH -N 1 -n8 --gpus-per-task=1 --gpu-bind=none

cat << EOF > select_gpu
#!/bin/bash

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
exec \$*
EOF

chmod +x ./select_gpu

CPU_BIND="mask_cpu:7e000000000000,7e00000000000000"
CPU_BIND="${CPU_BIND},7e0000,7e000000"
CPU_BIND="${CPU_BIND},7e,7e00"
CPU_BIND="${CPU_BIND},7e00000000,7e0000000000"

. ~/chromaform/env.sh
. ~/chromaform/env_extra.sh
#module list
export OMP_NUM_THREADS=6
export OPENBLAS_NUM_THREADS=1
#export ROCR_VISIBLE_DEVICES="0,1,2,3,4,5,6,7"
#export QUDA_ENABLE_P2P=0
#export QUDA_ENABLE_GDR=0
#export QUDA_ENABLE_NVSHMEM=0
#export QUDA_ENABLE_MPS=0

rm -f gprop32.sdb

srun --cpu-bind=threads --threads-per-core=1 -c6
$HOME/chromaform/install/chroma-quda-qdp-jit-double-nd4-cmake/bin/chroma
-i gprops32_quda.xml -geom 1 2 2 2 -poolsize 0k  -pool-max-alloc 0
-pool-max-alignment 512
