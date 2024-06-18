#!/bin/bash
cfg=$1



scratch_dir=/volatile/JLabLQCD/jkarpie/E5/run_dirs/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="da_bundle_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


OMP_NUM_THREADS=128
chromaform="/work/JLabLQCD/jkarpie/chromaform_restructure/"
chroma="${chromaform}/install/chroma-mgproto-qphix-qdpxx-double-nd4-avx512-superbblas-cpu/bin/chroma"
CHROMA_EX="-by 4 -bz 4 -pxy 0 -pxyz 0 -c $OMP_NUM_THREADS -sy 1 -sz 1 -minct 1"
GEOM="-geom 1 1 1 1"

pushd ${scratch_dir}/out/

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_${cfg}
#SBATCH --job-name=da_${cfg}
#SBATCH -A Delta
#SBATCH -q phi
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=1

export SLURM_CPU_BIND="cores"
module load python

. $chromaform/env.sh

module load python



export OMP_NUM_THREADS=128

# Place to put new databases
mkdir -p  /volatile/JLabLQCD/jkarpie/E5/mes_2pt_test_cpu/${cfg}
rm        /volatile/JLabLQCD/jkarpie/E5/mes_2pt_test_cpu/${cfg}/*


/work/JLabLQCD/jkarpie/run_scripts/chroma_python/pseudo_da_cls_bundle_cpu.py \
     -g "/cache/isoClover/E5g-transfer/64x32x32x32b5.30k0.13625c1.90952id9n" \
     -k 8 -c $cfg -r 4.0 -p 8 \
     -s "/volatile/JLabLQCD/jkarpie/E5/mes_2pt_test_cpu/" \
     -w /work/JLabLQCD/jkarpie/run_scripts/chroma_python/wfs/ > ${scratch_dir}/xml/${name_stem}.ini.xml

srun $chroma -i ${scratch_dir}/xml/${name_stem}.ini.xml -o ${scratch_dir}/xml/${name_stem}.out.xml ${CHROMA_EX} ${GEOM} 

EOF

sbatch ${filename}

popd
