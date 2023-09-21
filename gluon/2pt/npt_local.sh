#!/bin/bash

ExeDir=`pwd`
# source /home1/06377/tg856768/builds/xsede/frontera/scalar_had-node-libs/env_frontera_scalar.sh
source /global/cfs/cdirs/hadron/chromaform-perlmutter/env.sh


#INPUTS
#TOFFSET MOMX MOMY MOMZ CFG PHASEZ stream

#################
# GLOBAL PARAMS
#################
stream=$7
export ENSEM=cl21_32_64_b6p3_m0p2350_m0p2050
export BETA=b6p3
#PROJ IS LOCATION OF INPUT DATA
export PROJ=/pscratch/sd/j/jkarpie/${ENSEM}_extension/${ENSEM}-$stream
#Location of chroma_python
PYDIR=/global/homes/j/jkarpie/run_scripts/chroma_python
TSIZE=64
NVEC=64
#-------------------------------------------------------------------

#################################
# SWITCHES
#################################
#OPDISPS='all'
OPDISPS='local'
SFACT=0.08 # stout smearing factor
SNUM=10    # iterations of stout smearing
#------------------------------------------

##################################
# USER INPUT
##################################
CFG=$5
TOFFSET=$1
TCORR=16; NT_FWD=$TCORR
export PHASE=$6
export PHASEDIR=d001_${PHASE}

MOMX=$2; MOMY=$3; MOMZ=$4
MOM="${MOMX}.${MOMY}.${MOMZ}"

conjMomX=`echo "-1*$MOMX" | bc`
conjMomY=`echo "-1*$MOMY" | bc`
conjMomZ=`echo "-1*$MOMZ" | bc`
CONJMOM="${conjMomX}.${conjMomY}.${conjMomZ}"

momxMod=`echo "sqrt($MOMX*$MOMX)" | bc `
momyMod=`echo "sqrt($MOMY*$MOMY)" | bc `
momzMod=`echo "sqrt($MOMZ*$MOMZ)" | bc `
MODMOM="${momxMod}.${momyMod}.${momzMod}"
export momLabel=`echo $MOM | awk -F'.' '{printf $1$2$3}'`
#----------------------------------------------------------------


################################################
# SET T_ORIGIN BASED ON CFG & TSIZE & T_OFFSET
################################################
#T_INI=`/home1/06377/tg856768/RUNS/set_tsrc.pl $CFG $TSIZE | awk '{printf $6"\n"}'`
# I DISLIKE THIS RANDOM NUMBER AND IM NOT USING IT
T_INI=0
T_ORIGIN=$(( ( $T_INI + $TOFFSET ) % $TSIZE ))
#-----------------------------------------------------------------------------------


#################################################
# DETERMINE THE STAR(P)
#################################################
LG=''
# Catch number of zeros in MODMOM string
modmomZeroes=`echo $MODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep 0 | wc -l`
uniqNonZero=`echo $MODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep -v 0 | sort -u | wc -l`

if [ $modmomZeroes -eq 3 ]; then
    LG=G1g
elif [ $modmomZeroes -eq 2 ]; then
    LG=D4
elif [ $modmomZeroes -eq 1 ] && [ $uniqNonZero -eq 1 ]; then
    LG=D2
elif [ $modmomZeroes -eq 0 ] && [ $uniqNonZero -eq 1 ]; then
    LG=D3
elif [ $modmomZeroes -eq 1 ] && [ $uniqNonZero -eq 2 ]; then
    LG=C4mn0
elif [ $modmomZeroes -eq 0 ] && [ $uniqNonZero -eq 2 ]; then
    LG=C4nnm
else
    LG=C2nmp
fi
#-------------------------------------------------------------------
echo "Little group = $LG"


####################################################
# SET OPERATOR LIST BASED ON STAR(P)
####################################################
list_dir=$PYDIR/nuc_op_lists/colin_nuc_lists/
if [ $LG == G1g ]; then
    nucOps=${list_dir}/nucleon.G1g.rest.local.list
    #nucOps=${list_dir}/nucleon.G1g.rest.list
elif [ $LG == D4 ]; then
    nucOps=${list_dir}/nucleon.D4E1-H1o2-n00.inflight.list
elif [ $LG == D2 ]; then
    nucOps=${list_dir}/nucleon.D2E-H1o2-nn0.inflight.list
elif [ $LG == D3 ]; then
    nucOps=${list_dir}/nucleon.D3E1-H1o2-nnn.inflight.list
elif [ $LG == C4mn0 ]; then
    nucOps=${list_dir}/nucleon.C4nm0E-H1o2-nm0.inflight.list
elif [ $LG == C4nnm ]; then
    nucOps=${list_dir}/nucleon.C4nnmE-H1o2-nnm.inflight.list
else
    echo "Don't yet have an operator list for $LG!"
    exit 33
fi
#--------------------------------------------------------------------------------------------------




########################
# I/Os
########################
#### ORIGINAL CFG FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050_cfg_1000.lime
#CFGPREF_CHR="/work2/06377/tg856768/frontera/isoClover/${BETA}/${ENSEM}/cfgs/${ENSEM}_cfg"
#### MY CFG FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_cfg_11000.lime
CFGPREF_CHR="${PROJ}/cfgs/${ENSEM}-${stream}_cfg"

#### ORIGINAL EIG FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050.3d.eigs.mod4350
#CVEC=${PROJ}/eigs_mod/${ENSEM}.3d.eigs
#### MY EIG FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_eigen_z0_light.11000.eig
CVEC="${PROJ}/eig/${ENSEM}-${stream}_eigen_z0_light"

# run_dir needs to be changed to tell it where to put log files, xmls, and submission files
run_dir="/pscratch/sd/j/jkarpie/redstar_run/"
LOG=''; OUT=''
if [ $PHASE == '0.00' ]; then
    #### ORIGINAL PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050.prop.n192.light.t0_0.sdb1020
    #PERAM=/work2/06377/tg856768/frontera/isoClover/${BETA}/${ENSEM}/prop_db/${ENSEM}.prop.n${NVEC}.light.t0_${TOFFSET}
    #### MY PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_z2_light_peram.11000.T60.peram
    PERAM=${PROJ}/peram/${CFG}/${ENSEM}-${stream}_z0_light_peram
    DUMP=/tmp/${USER}/nuc_runs/${ENSEM}/2pt/unphased/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}
    LOG=${run_dir}/${ENSEM}/${ENSEM}-${stream}/out_z0

    BOP=${DUMP}/run${CFG}/${ENSEM}.n${NVEC}.t0_${TOFFSET}.NtFwd_${NT_FWD}.baryon.colorvec
    OUT=${PROJ}/2ptcorrs/unphased
else
    ## JK DOESN'T KNOW WHAT THIS WAS ABOUT
    ## d001_2.00 phased perambulators apparently have 96 evecs stored for toffset=0,16
    #NVECTMP=$NVEC
    #if [[ ( $TOFFSET -eq 0 || $TOFFSET -eq 16 ) && $PHASE == '2.00' ]]; then NVECTMP=96; fi

    #### ORIGINAL PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050.prop.n192.light.t0_0.sdb1020
    #PERAM=${PROJ}/phased/prop_db/d001_${PHASE}/${ENSEM}.phased_${PHASE}.prop.n${NVECTMP}.light.t0_${TOFFSET}
    #### MY PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_z2_light_peram.11000.T60.peram
    PERAM=${PROJ}/peram/${CFG}/${ENSEM}-${stream}_z${PHASE}_light_peram
    DUMP=/tmp/${USER}/nuc_runs/${ENSEM}/2pt/phased/${PHASEDIR}/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}
    LOG=/scratch3/06377/tg856768/nuc_runs/${ENSEM}/2pt/phased/${PHASEDIR}
    LOG=${run_dir}/${ENSEM}/${ENSEM}-${stream}/out_z$PHASE

    BOP=${DUMP}/run${CFG}/${ENSEM}.n${NVEC}.phased_${PHASE}.t0_${TOFFSET}.NtFwd_${NT_FWD}.baryon.colorvec
    OUT=${PROJ}/2ptcorrs/phased/${PHASEDIR}
fi
echo "DUMPBASE = ${DUMP}"
echo "LOGBASE  = ${LOG}"
echo "OUTBASE  = ${OUT}"


# Make the final output and log directory trees
LOG=${LOG}/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}
OUT=${OUT}/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}/SDB
mkdir -p $OUT $LOG $DUMP
# mkdir -p $OUT $DUMP

# Final Correlator
DB=${OUT}/${ENSEM}.nuc_${OPDISPS}.row1.p${MOMX}${MOMY}${MOMZ}.n${NVEC}.t0_${TOFFSET}.tcorr_${TCORR}
#----------------------------------------------------------------------------------------------------



########################
# GET TO WORK
########################
echo "Doing CFG = $CFG"
# Remove old run dirs; make anew and bump to them
rm -rf ${LOG}/run$CFG
mkdir -p ${LOG}/run$CFG
# pushd ${LOG}/run$CFG

rm ${DB}.sdb$CFG
rm -rf ${DUMP}/run$CFG
mkdir -p ${DUMP}/run$CFG
pushd ${DUMP}/run$CFG


# Pull all the needed input from /scratch to /tmp
rsync -L ${PERAM}.${CFG}.T${TOFFSET}.peram ${DUMP}/run${CFG}/
rsync -L ${CVEC}.${CFG}.eig ${DUMP}/run${CFG}/
# Now modify the prefixes to be passed
CVEC=${DUMP}/run${CFG}/${ENSEM}-${stream}_eigen_z0_light
if [ $PHASE == '0.00' ]; then
    PERAM=${DUMP}/run${CFG}/${ENSEM}-${stream}_z0_light_peram
else
    PERAM=${DUMP}/run${CFG}/${ENSEM}-${stream}_z${PHASE}_light_peram
fi
#--------------------------------------------------------------------------------------------------





################################################
################################################
# Make the elementals on the fly!
# Pass a single <momx>.<momy>.<momz> combo
# conjugate momentum made as well!
################################################
################################################
XMLI=baryon_elem${STREAM}.${OPDISPS}.n${NVEC}.phase_${PHASE}.t0_${TOFFSET}.NtFwd_${NT_FWD}.ini.xml$CFG
XMLO=`echo $XMLI | sed -e 's/ini/out/'`
mkdir -p bop_xmls

$PYDIR/baryon_elem_jknames.py -c $CFG -e $ENSEM -g $CFGPREF_CHR -n $NVEC \
    -t $T_ORIGIN -T $NT_FWD -v $CVEC -m ${MOM}/${CONJMOM} -b ${BOP}.sdb$CFG -d $OPDISPS \
    --gaugeSmear --smearFact=$SFACT --smearNum=$SNUM \
    --superb --phase "0.0 0.0 $PHASE" > bop_xmls/$XMLI
# --haromOptimize > bop_xmls/$XMLI


export OMP_NUM_THREADS=1

chromaform="/global/cfs/cdirs/hadron/chromaform-perlmutter/"
CHROMA="${chromaform}/install-jk-cpu/chroma-mgproto-qphix-qdpxx-double-nd4-avx2-superbblas-cpu/bin/chroma"
CHROMA_EX="-by 4 -bz 4 -pxy 0 -pxyz 0 -c $OMP_NUM_THREADS -sy 1 -sz 1 -minct 1"
GEOM="-geom 2 4 4 4"

srun $CHROMA $CHROMA_EX $GEOM -i bop_xmls/$XMLI >& ${LOG}/run${CFG}/BOP${CFG}

#---------------------------------------------------------------------------------------------------

#### I don't know what these do but I don't think it's for perlmutter
####export NPT_BATCH_SIZE=1
####export KMP_AFFINITY=scatter,granularity=fine

echo "Setting up the input files for redstar"    
#########################
# XMLS FOR THIS OPERATOR
#########################
${PYDIR}/redstar_2pt_jknames.py -c $CFG -e $ENSEM -i $nucOps -f $nucOps \
    -p $MOM -r $TCORR -t $T_ORIGIN \
    -s 0 -n "smeared_hadron_node" -u "unsmeared_hadron_node" -o $DB \
    -y "baryon_2pt" -g "." -x 0 --no_writing_nodes \
    --nvecs=$NVEC --prop_db_prefix=$PERAM -b $BOP -v 12 >> nucleon_control.xml$CFG

# Need to fixx placement of thrreads on cores
echo "Running redstar at " `date`

source ${chromaform}/env.sh

/global/homes/j/jkarpie/run_scripts/gluon/run_redstar_int.2pt.no-nodes.sh \
    nucleon_control.xml$CFG >& ${LOG}/run${CFG}/DB$CFG

echo "Ending redstar script at time= " `date`

popd

# # Cleanup $DUMP and $LOG
# rm -r ${DUMP}/run$CFG/
# rm -r ${LOG}/run$CFG/


exit 0
