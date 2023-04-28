#!/bin/bash
cfg=$1



scratch_dir=/pscratch/sd/j/jkarpie/da/E5/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="da_bundle_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


chromaform="/global/cfs/cdirs/hadron/chromaform-perlmutter"
chroma="$chromaform/install/chroma-quda-qdp-jit-double-nd4-cmake-superbblas-cuda/bin/chroma"

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_${cfg}
#SBATCH --job-name=da_${cfg}
#SBATCH -A hadron_g
#SBATCH -q regular
#SBATCH -t 2:00:00
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --ntasks-per-node=4
#SBATCH -C gpu --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"


. $chromaform/env.sh
. $chromaform/env_extra.sh
module load python

# Place to put new databases
mkdir -p  /global/cfs/cdirs/hadron/CLS_Nf2/E5/mes_2pt/${cfg}
rm /global/cfs/cdirs/hadron/CLS_Nf2/E5/mes_2pt/${cfg}/*


#/global/homes/j/jkarpie/run_scripts/chroma_python/pseudo_da_cls.py \
#     -g "/global/cfs/cdirs/hadron/CLS_Nf2/E5/cfgs/64x32x32x32b5.30k0.13625c1.90952id9n" \
#     -k \${k} -z \${zeta} -c $cfg -r 4.0 -p 8 \
#     -s "/global/cfs/cdirs/hadron/CLS_Nf2/E5/mes_2pt/" \
#     -w /global/homes/j/jkarpie/run_scripts/chroma_python/wfs/ > xml

/global/homes/j/jkarpie/run_scripts/chroma_python/pseudo_da_cls_bundle.py \
     -g "/global/cfs/cdirs/hadron/CLS_Nf2/E5/cfgs/64x32x32x32b5.30k0.13625c1.90952id9n" \
     -k 8 -c $cfg -r 4.0 -p 8 \
     -s "/global/cfs/cdirs/hadron/CLS_Nf2/E5/mes_2pt/" \
     -w /global/homes/j/jkarpie/run_scripts/chroma_python/wfs/ > ${scratch_dir}/xml/${name_stem}.ini.xml

srun $chroma -i ${scratch_dir}/xml/${name_stem}.ini.xml -o ${scratch_dir}/xml/${name_stem}.out.xml  -geom 1 1 1 4 -pool-max-alignment 512 -pool-max-alloc 0 

EOF

sbatch ${filename}

popd
