#!/bin/bash
cfg=$1


stream=10700
cfg_stem="cl21_32_64_b6p3_m0p2350_m0p2050"

zeta=0

file_stem="${cfg_stem}-${stream}_eigen_z${zeta}_light.${cfg}"





chroma="/project/projectdirs/hadron/chromaform0/install-knl/chroma-mgproto-qphix-avx512/bin/chroma "

cfg_file="/global/cfs/cdirs/hadron/cl21_32_64_b6p3_m0p2350_m0p2050_extension/${cfg_stem}-${stream}/cfgs/${cfg_stem}-${stream}_cfg_${cfg}.lime"


cat << EOF > sub_files/${file_stem}.sh
#!/bin/bash
#SBATCH -t 12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --constraint=knl
#SBATCH -A hadron
#SBATCH --qos=regular
#SBATCH -J eig-${cfg}-${stream}

export MKL_NUM_THREADS=64
export OMP_NUM_THREADS=64
export OMP_PLACES=threads
export OMP_PROC_BIND=true

./make_eigen_xml.sh xml/${file_stem}.ini.xml $cfg_file eig/${file_stem}.eig peram/${file_stem}.peram

srun -c 68 --cpu_bind=cores \
  $chroma -by 4 -bz 4 -pxy 0 -pxyz 0 -c 64 -sy 1 -sz 1 -minct 1 -poolsize 1 -geom 1 2 2 1 \
  -i xml/${file_stem}.ini.xml -o xml/${file_stem}.out.xml >& out/${file_stem}.out

EOF

sbatch sub_files/${file_stem}.sh
