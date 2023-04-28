#!/bin/bash
cfg=$1
stream=$2
zeta=$3
dep=$4


cfg_stem="cl21_32_64_b6p3_m0p2350_m0p2050"
file_stem="${cfg_stem}-${stream}_peram_z${zeta}_light"






chromaform=/lus/grand/projects/SpectStructHadron/chromaform
chroma=$chromaform/install/chroma-quda-qdp-jit-double-nd4-superbblas-cuda/bin/chroma


cat << EOF > sub_files/${file_stem}.${cfg}.sh
#!/bin/bash
#PBS -A SpectStructHadron
#PBS -l walltime=04:00:00
#PBS -l select=64:ncpus=64:ngpus=4:system=polaris
#PBS -q prod
#PBS -j oe
#PBS -k doe
#PBS -m n
#PBS -l filesystems=home:grand
#PBS -N prop-${cfg}-${stream}

# The rest is an example of how an MPI job might be set up
echo Working directory is \$PBS_O_WORKDIR
cd \$PBS_O_WORKDIR

echo Jobid: \$PBS_JOBID
echo Running on host \`hostname\`
echo Running on nodes \`cat \$PBS_NODEFILE\`

NNODES=\`wc -l < \$PBS_NODEFILE\`
NNODES_PER_JOB=1
NRANKS=4           # Number of MPI ranks per node
NDEPTH=1           # Number of hardware threads per rank, spacing between MPI ranks on a node
NTHREADS=1        # Number of OMP threads per rank, given to OMP_NUM_THREADS

NTOTRANKS=\$(( NNODES_PER_JOB * NRANKS ))

echo "NUM_OF_NODES=\${NNODES}  TOTAL_NUM_RANKS=\${NTOTRANKS}
RANKS_PER_NODE=\${NRANKS}  THREADS_PER_RANK=\${NTHREADS}"

. $chromaform/env_extra.sh

export QUDA_ENABLE_P2P=0    # P2P can still have issues so disable
export QUDA_ENABLE_GDR=0    # You need a GDR capable MPI for this to work, so disable


split --lines=\${NNODES_PER_JOB} --numeric-suffixes=1 --suffix-length=2 \$PBS_NODEFILE hostfiles/local_hostfile.${cfg}.\$PBS_JOBID.
T=0
for lh in hostfiles/local_hostfile.${cfg}.\$PBS_JOBID*
do
  echo "Cfg: ${cfg} T: \${T} Launching mpiexec w/ \${lh} "
cfg_file="/lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/cfgs/${cfg_stem}-${stream}_cfg_${cfg}.lime"

file_s=${file_stem}.${cfg}.T\${T}

mkdir -p  /lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/peram/${cfg}
eig_file="/lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/eig/${cfg_stem}-${stream}_eigen_z${zeta}_light.${cfg}.eig"
./make_peram_xml.sh xml/\${file_s}.ini.xml \$cfg_file \${eig_file} /lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/peram/${cfg}/\${file_s}.peram \$T

if [ -f /lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/peram/${cfg}/\${file_s}.peram ]
then
rm /lus/grand/projects/SpectStructHadron/${cfg_stem}/${cfg_stem}-${stream}/peram/${cfg}/\${file_s}.peram
fi

mpiexec  --hostfile \${lh} --np \${NTOTRANKS} -ppn \${NRANKS} -d \${NDEPTH} -env OMP_NUM_THREADS=\${NTHREADS} -env CUDA_VISIBLE_DEVICES=0,1,2,3 \
  $chroma  -geom 1 1 2 2 -pool-max-alloc 0 -pool-max-alignment 512 \
  -libdevice-path /opt/nvidia/hpc_sdk/Linux_x86_64/21.9/cuda/11.4/nvvm/libdevice \
  -i xml/\${file_s}.ini.xml -o xml/\${file_s}.out.xml >& out/\${file_s}.out &
T=\$((T+1))
done

wait

EOF

if [ $dep -eq -1 ]
then
qsub  sub_files/${file_stem}.${cfg}.sh
else
qsub -W depend=afterok:${dep} sub_files/${file_stem}.${cfg}.sh
fi
