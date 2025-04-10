#!/bin/bash
cfg=$1




ensemb="cl21_64_192_b6p7_m0p1830_m0p1650"
beta="b6p7"


scratch_dir=/pscratch/sd/j/jkarpie/qtop/${beta}/${ensemb}
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="qtop_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh

cfg_dir="/pscratch/sd/j/jkarpie/chris_dump/b6p7/cfgs"

OMP_NUM_THREADS=128
chromaform="$CFS/hadron/chromaform-perlmutter/"
chroma="${chromaform}/install-jk-cpu/chroma-mgproto-qphix-qdpxx-double-nd4-avx2-superbblas-cpu/bin/chroma"
CHROMA_EX="-by 4 -bz 4 -pxy 0 -pxyz 0 -c $OMP_NUM_THREADS -sy 1 -sz 1 -minct 1"
GEOM="-geom 1 1 2 4"

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_${cfg}
#SBATCH --job-name=qtop_${cfg}
#SBATCH -A hadron
#SBATCH -q regular
#SBATCH -C cpu
#SBATCH -t 08:00:00
#SBATCH --nodes 8
#SBATCH --ntasks 8 
#SBATCH --cpus-per-task 128
#SBATCH --ntasks-per-node=1

export SLURM_CPU_BIND="cores"
module load python

source $chromaform/env.sh
source $chromaform/env_extra.sh

module load python


/global/homes/j/jkarpie/run_scripts/gluon/make_qtop_xml.sh ${scratch_dir}/xml/${name_stem}.ini.xml ${cfg_dir}/${ensemb}_cfg_${cfg}.lime ${cfg}


srun $chroma -i ${scratch_dir}/xml/${name_stem}.ini.xml -o ${scratch_dir}/xml/${name_stem}.out.xml ${CHROMA_EX} ${GEOM} 

EOF

sbatch ${filename}
popd

