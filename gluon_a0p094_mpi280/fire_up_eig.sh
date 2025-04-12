#!/bin/bash
cfg=$1
Nevec=192

here=`pwd`

ensemb="cl21_32_64_b6p3_m0p2390_m0p2050"

data_dir="/global/cfs/projectdirs/hadron/b6p3/${ensemb}/"
mkdir -p ${data_dir}/eigs_mod/
eig_out=${data_dir}/eigs_mod/${ensemb}.3d.eigs${Nevec}.mod${cfg} 
scratch=/pscratch/sd/j/jkarpie
scratch_dir=${scratch}/eig_run/$ensemb/
mkdir -p ${scratch_dir}/sub
mkdir -p ${scratch_dir}/xml
mkdir -p ${scratch_dir}/out


name_stem="eig_${cfg}"
filename=${scratch_dir}/sub/${name_stem}.sh


chromaform="/pscratch/sd/e/eromero/chromaform-gpu"
chroma="$chromaform/install/chroma-restructure-quda-qdp-jit-double-nd4-cmake-superbblas-cuda/bin/chroma"

pushd ${scratch_dir}/out

cat <<EOF > ${filename}
#!/bin/bash
#SBATCH -o out_eig_${cfg}
#SBATCH --job-name=${cfg}_eig
#SBATCH -A hadron_g
#SBATCH -q regular
#SBATCH -t 0:30:00
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --ntasks-per-node=4
#SBATCH -C gpu --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"

export QUDA_ENABLE_GDR=0


source $chromaform/env.sh
source $chromaform/env_extra.sh
module load python


/global/homes/j/jkarpie/run_scripts/gluon_a0p094_mpi280/make_eigen_xml.sh ${Nevec} \
      ${scratch_dir}/xml/${name_stem}_T${T}.ini.xml \
      ${data_dir}/cfgs/${ensemb}_cfg_${cfg}.lime \
      $eig_out


if [ -f $eig_out ]
then
rm ${eig_out}
fi

module list


srun   $chroma -i ${scratch_dir}/xml/${name_stem}_T${T}.ini.xml -o ${scratch_dir}/xml/${name_stem}_T${T}.out.xml  -pool-max-alignment 512 -pool-max-alloc 0 -geom 1 1 1 4

${here}/fire_up_peram_all_T.sh $cfg $Nevec
${here}/fire_up_peram_all_T_strange.sh $cfg $Nevec


EOF

sbatch ${filename}

popd
