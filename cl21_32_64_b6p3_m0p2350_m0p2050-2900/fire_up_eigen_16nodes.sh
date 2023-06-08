#!/bin/bash
cfg=$1


stream=8200
cfg_stem="cl21_32_64_b6p3_m0p2350_m0p2050"

zeta=0

file_stem="${cfg_stem}-${stream}_eigen_z${zeta}_light.${cfg}"


cfg_file="/lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/cfgs/${cfg_stem}-${stream}_cfg_${cfg}.lime"


chromaform=/lus/grand/projects/SpectStructHadron/chromaform
chroma=$chromaform/install/chroma-quda-qdp-jit-double-nd4-superbblas-cuda/bin/chroma


cat << EOF > sub_files/${file_stem}.sh
#!/bin/bash
#PBS -A SpectStructHadron
#PBS -l walltime=00:30:00
#PBS -l select=16:ncpus=64:ngpus=4:system=polaris
#PBS -q debug
#PBS -k doe
#PBS -o t_quda.out
#PBS -j oe
#PBS -m n
#PBS -l filesystems=home:grand
#PBS -N eig-${cfg}-${stream}

# The rest is an example of how an MPI job might be set up
echo Working directory is \$PBS_O_WORKDIR
cd \$PBS_O_WORKDIR

echo Jobid: \$PBS_JOBID
echo Running on host \`hostname\`
echo Running on nodes \`cat \$PBS_NODEFILE\`

NNODES=\`wc -l < \$PBS_NODEFILE\`
NRANKS=4           # Number of MPI ranks per node
NDEPTH=1           # Number of hardware threads per rank, spacing between MPI ranks on a node
NTHREADS=16        # Number of OMP threads per rank, given to OMP_NUM_THREADS

NTOTRANKS=\$(( NNODES * NRANKS ))

echo "NUM_OF_NODES=\${NNODES}  TOTAL_NUM_RANKS=\${NTOTRANKS}
RANKS_PER_NODE=\${NRANKS}  THREADS_PER_RANK=\${NTHREADS}"

. $chromaform/env_extra.sh

export QUDA_ENABLE_P2P=0    # P2P can still have issues so disable
export QUDA_ENABLE_GDR=0    # You need a GDR capable MPI for this to work, so disable


./make_eigen_xml.sh xml/${file_stem}.ini.xml $cfg_file /lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/eig/${file_stem}.eig 

mpiexec --np \${NTOTRANKS} -ppn \${NRANKS} -d \${NDEPTH} -env OMP_NUM_THREADS=\${NTHREADS} -env CUDA_VISIBLE_DEVICES=0,1,2,3 \
  $chroma  -geom 2 2 2 8 -pool-max-alloc 0 -pool-max-alignment 512 \
  -libdevice-path /opt/nvidia/hpc_sdk/Linux_x86_64/21.9/cuda/11.4/nvvm/libdevice \
  -i xml/${file_stem}.ini.xml -o xml/${file_stem}.out.xml >& out/${file_stem}.out

EOF

qsub sub_files/${file_stem}.sh
