#!/bin/bash
cfg_start=$1
Nevec=192

here=`pwd`

ensemb="cl21_48_128_b6p5_m0p2070_m0p1750"

data_dir="/global/cfs/projectdirs/hadron/b6p5/${ensemb}/"
mkdir -p ${data_dir}/eigs_mod/
scratch=/pscratch/sd/j/jkarpie
scratch_dir=${scratch}/eig_run/$ensemb/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="eig"
filename=${scratch_dir}/sub/${name_stem}_${cfg_start}.sh


chromaform="/pscratch/sd/e/eromero/chromaform-gpu"
chroma="$chromaform/install/chroma-restructure-quda-qdp-jit-double-nd4-cmake-superbblas-cuda/bin/chroma"

cfg_list={${cfg_start}..$((cfg_start+249))..10}

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_eig_${cfg_start}
#SBATCH --job-name=${cfg_start}_eig
#SBATCH -A hadron_g
#SBATCH -q regular
#SBATCH -t 06:00:00
#SBATCH -N 25
#SBATCH -c 16
#SBATCH --ntasks-per-node=4
#SBATCH -C gpu --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"

export QUDA_ENABLE_GDR=0


source $chromaform/env.sh
source $chromaform/env_extra.sh
module load python

for cfg in $cfg_list
do
eig_out=${data_dir}/eigs_mod/${ensemb}.3d.eigs${Nevec}.mod\${cfg} 
name_stem=${name_stem}_\${cfg}
/global/homes/j/jkarpie/run_scripts/gluon_a0p073_mpi280/make_eigen_xml.sh ${Nevec} \
      ${scratch_dir}/xml/\${name_stem}.ini.xml \
      ${data_dir}/cfgs/${ensemb}_cfg_\${cfg}.lime \
      \$eig_out


if [ -f \$eig_out ]
then
rm \${eig_out}
fi

module list


srun  -N1 -n4 -c16  $chroma -i ${scratch_dir}/xml/\${name_stem}.ini.xml -o ${scratch_dir}/xml/\${name_stem}_T${T}.out.xml  -pool-max-alignment 512 -pool-max-alloc 0 -geom 1 1 1 4



done

wait 

${here}/fire_up_peram_all_T_big.sh $cfg_start $Nevec
${here}/fire_up_peram_all_T_big_strange.sh $cfg_start $Nevec

EOF

sbatch ${filename}

popd
