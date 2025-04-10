#!/bin/bash
cfg_start=$1
Nevec=$2



ensemb="cl21_32_64_b6p3_m0p2390_m0p2050"

data_dir="/global/cfs/projectdirs/hadron/b6p3/${ensemb}/"

scratch=/pscratch/sd/j/jkarpie
scratch_dir=${scratch}/peram_run/$ensemb/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="peram_bundle_${cfg_start}"
filename=${scratch_dir}/sub/${name_stem}.sh


chromaform="/pscratch/sd/e/eromero/chromaform-gpu"
chroma="$chromaform/install/chroma-restructure-quda-qdp-jit-double-nd4-cmake-superbblas-cuda/bin/chroma"
cfg_list={${cfg_start}..$((cfg_start+249))..10}

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_peram_${cfg_start}
#SBATCH --job-name=${cfg_start}_prop
#SBATCH -A hadron_g
#SBATCH -q regular
#SBATCH -t 6:00:00
#SBATCH -N 150
#SBATCH -c 16
#SBATCH --ntasks-per-node=4
#SBATCH -C gpu --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"

export QUDA_ENABLE_GDR=0


. $chromaform/env.sh
. $chromaform/env_extra.sh
module load python


for cfg in $cfg_list
do

eig_out=${data_dir}/eigs_mod/${ensemb}.3d.eigs${Nevec}.mod\${cfg}

for zeta in 0 2 -2
do

name_stem="peram_bundle_\${cfg}_z\${zeta}"
peram_out=${scratch}/${ensemb}/prop_db/\${cfg}/${ensemb}.prop.n${Nevec}.light.z\${zeta}
mkdir -p ${scratch}/${ensemb}/prop_db/\${cfg}

/global/homes/j/jkarpie/run_scripts/gluon/make_peram_xml_zeta_all_T.sh \
      ${scratch_dir}/xml/\${name_stem}.ini.xml \
      \${cfg} \
      ${data_dir}/cfgs/${ensemb}_cfg_\${cfg}.lime \
      \$eig_out \
      \${peram_out} \
      63 \
      \$zeta \
      $Nevec

rm \$peram_out

srun -N2 -n8 -c16  $chroma -i ${scratch_dir}/xml/\${name_stem}.ini.xml -o ${scratch_dir}/xml/\${name_stem}.out.xml  -pool-max-alignment 512 -pool-max-alloc 0 -geom 1 1 2 4 &

done
done
wait


EOF

sbatch ${filename}

popd

