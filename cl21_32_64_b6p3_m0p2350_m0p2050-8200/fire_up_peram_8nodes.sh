#!/bin/bash
cfg=$1
eig_job_id=$2


N=2

stream=10700
cfg_stem="cl21_32_64_b6p3_m0p2350_m0p2050"

zeta=0

ofile_stem="${cfg_stem}-${stream}_z${zeta}_light_peram.${cfg}"


eig_file="eig/${cfg_stem}-${stream}_eigen_z${zeta}_light.${cfg}.eig"


chroma="/project/projectdirs/hadron/chromaform0/install-knl/chroma-mgproto-qphix-avx512/bin/chroma "

cfg_file="/global/cfs/cdirs/hadron/cl21_32_64_b6p3_m0p2350_m0p2050_extension/${cfg_stem}-${stream}/cfgs/${cfg_stem}-${stream}_cfg_${cfg}.lime"


cat << EOF > sub_files/${ofile_stem}.sh
#!/bin/bash
#SBATCH -t 08:00:00
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=4
#SBATCH --constraint=knl
#SBATCH -A hadron
#SBATCH --qos=regular
#SBATCH -J peram-${cfg}-${stream}
#SBATCH --array=0-64

export MKL_NUM_THREADS=64
export OMP_NUM_THREADS=64
export OMP_PLACES=threads
export OMP_PROC_BIND=true

T=\$SLURM_ARRAY_TASK_ID

file_stem=${ofile_stem}.T\${T}

./make_peram_xml.sh xml/\${file_stem}.ini.xml $cfg_file ${eig_file} peram/\${file_stem}.peram \$T

$SLURM_JOB_ID


srun -c 68 --cpu_bind=cores \
  $chroma -by 4 -bz 4 -pxy 0 -pxyz 0 -c 64 -sy 1 -sz 1 -minct 1 -poolsize 1 -geom 2 2 2 4 \
  -i xml/\${file_stem}.ini.xml -o xml/\${file_stem}.out.xml >& out/\${file_stem}.out

EOF

sbatch sub_files/${ofile_stem}.sh
#sbatch --dependency=afterany:${eig_job_id}  sub_files/${file_stem}.sh
