#!/bin/bash
cfg=$1
stream=$2

for zeta in 0 2 -2
do


ensemb="cl21_32_64_b6p3_m0p2350_m0p2050"

scratch=/pscratch/sd/j/jkarpie
scratch_dir=${scratch}/peram_run/$ensemb/${ensemb}-${stream}/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="peram_bundle_${cfg}_z${zeta}"
filename=${scratch_dir}/sub/${name_stem}.sh


chromaform="/global/cfs/cdirs/hadron/chromaform-perlmutter"
chroma="$chromaform/install/chroma-quda-qdp-jit-double-nd4-cmake-superbblas-cuda/bin/chroma"

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_peram_${cfg}_z${zeta}
#SBATCH --job-name=z${zeta}_${cfg}_prop
#SBATCH -A hadron_g
#SBATCH -q regular
#SBATCH -t 4:00:00
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --ntasks-per-node=4
#SBATCH -C gpu --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"


. $chromaform/env.sh
. $chromaform/env_extra.sh
module load python


/global/homes/j/jkarpie/run_scripts/gluon/make_peram_xml_zeta_all_T.sh \
      ${scratch_dir}/xml/${name_stem}.ini.xml \
      ${scratch}/cl21_32_64_b6p3_m0p2350_m0p2050_extension/${ensemb}-${stream}/cfgs/${ensemb}-${stream}_cfg_${cfg}.lime \
      ${scratch}/cl21_32_64_b6p3_m0p2350_m0p2050_extension/${ensemb}-${stream}/eig/${ensemb}-${stream}_eigen_z0_light.${cfg}.eig \
      ${scratch}/cl21_32_64_b6p3_m0p2350_m0p2050_extension/${ensemb}-${stream}/peram/${cfg}/${ensemb}-${stream}_z${zeta}_light_peram.${cfg} \
      63 \
      $zeta 

mkdir -p ${scratch}/cl21_32_64_b6p3_m0p2350_m0p2050_extension/${ensemb}-${stream}/peram/${cfg}/

rm ${scratch}/cl21_32_64_b6p3_m0p2350_m0p2050_extension/${ensemb}-${stream}/peram/${cfg}/${ensemb}-${stream}_z${zeta}_light_peram.${cfg}.*peram

srun   $chroma -i ${scratch_dir}/xml/${name_stem}.ini.xml -o ${scratch_dir}/xml/${name_stem}.out.xml  -pool-max-alignment 512 -pool-max-alloc 0 -geom 1 1 1 4



EOF

sbatch ${filename}

popd

done
