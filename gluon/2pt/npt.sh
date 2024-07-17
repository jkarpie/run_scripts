#!/bin/bash

here="/qcd/work/JLabLQCD/jkarpie/run_scripts_24s/gluon/2pt"
# source /home1/06377/tg856768/builds/xsede/frontera/scalar_had-node-libs/env_frontera_scalar.sh


#INPUTS
#TOFFSET MOMX MOMY MOMZ CFG PHASEZ STREAM

stream=$7
#################
# GLOBAL PARAMS
#################
export ENSEM=cl21_32_64_b6p3_m0p2350_m0p2050
export BETA=b6p3
#PROJ IS LOCATION OF INPUT DATA
export PROJ=/qcd/cache/isoClover/${ENSEM}_extension/${ENSEM}-${stream}/
#Location of chroma_python
PYDIR=/qcd/work/JLabLQCD/jkarpie/run_scripts_24s/chroma_python
TSIZE=64
NVEC=64
#-------------------------------------------------------------------

#################################
# SWITCHES
#################################
OPDISPS='all'
#OPDISPS='local'
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


#momxMod=`echo "sqrt($MOMX*$MOMX)" | bc `
#momyMod=`echo "sqrt($MOMY*$MOMY)" | bc `
#momzMod=`echo "sqrt($MOMZ*$MOMZ)" | bc `
momxMod=${MOMX#-}
momyMod=${MOMY#-}
momzMod=${MOMZ#-}
MODMOM="${momxMod}.${momyMod}.${momzMod}"
export momLabel=`echo $MOM | awk -F'.' '{printf $1$2$3}'`
#----------------------------------------------------------------


################################################
# SET T_ORIGIN BASED ON CFG & TSIZE & T_OFFSET
################################################
#T_INI=`/home1/06377/tg856768/RUNS/set_tsrc.pl $CFG $TSIZE | awk '{printf $6"\n"}'`
# I DISLIKE THIS RANDOM NUMBER AND IM NOT USING IT

# Find t_origin
T_INI="$( perl -e "
   srand($CFG);

   # Call a few to clear out junk

   foreach \$i (1 .. 20)
   {
     rand(1.0);
   }
   \$t_origin = int(rand($TSIZE));
   print \"\$t_origin\\n\"
" )"

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
#### MY CFG FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_cfg_11000.lime
CFGPREF_CHR="${PROJ}/cfgs/${ENSEM}_cfg"

#### ORIGINAL EIG FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050.3d.eigs.mod4350
#CVEC=${PROJ}/eigs_mod/${ENSEM}.3d.eigs
#### MY EIG FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_eigen_z0_light.11000.eig
CVEC="${PROJ}/eigs_mod/${ENSEM}-${stream}_eigen_z0_light.${CFG}.eig"

# run_dir needs to be changed to tell it where to put log files, xmls, and submission files
run_dir="/qcd/volatile/JLabLQCD/jkarpie/redstar_run/"
LOG=''; OUT='' ; XML=''
if [ $PHASE == '0.00' ]; then
    #### ORIGINAL PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050.prop.n192.light.t0_0.sdb1020
    #PERAM=${PROJ}/prop_db/${ENSEM}.prop.n${NVEC}.light.t0_${TOFFSET}
    #### MY PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_z2_light_peram.11000.T60.peram
    PERAM=${PROJ}/peram/${CFG}/${ENSEM}-${stream}_peram_z0_light.${CFG}.T${TOFFSET}.peram
    DUMP=${run_dir}/${ENSEM}/2pt/unphased/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}
    LOG=${run_dir}/$ENSEM/${ENSEM}-${stream}/out
    XML=${run_dir}/$ENSEM/${ENSEM}-${stream}/xml


    BOP=/qcd/volatile/JLabLQCD/jkarpie/baryon_ops/${ENSEM}_extension/${ENSEM}-${stream}/dbs/$CFG/${ENSEM}-${stream}.n${NVEC}.t0_0.NtFwd_64.baryon.colorvec
    OUT=${PROJ}/2ptcorrs/unphased
else
    ## JK DOESN'T KNOW WHAT THIS WAS ABOUT
    ## d001_2.00 phased perambulators apparently have 96 evecs stored for toffset=0,16
    #NVECTMP=$NVEC
    #if [[ ( $TOFFSET -eq 0 || $TOFFSET -eq 16 ) && $PHASE == '2.00' ]]; then NVECTMP=96; fi

    #### ORIGINAL PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050.prop.n192.light.t0_0.sdb1020
    #PERAM=${PROJ}/phased/prop_db/d001_${PHASE}/${ENSEM}.phased_${PHASE}.prop.n${NVECTMP}.light.t0_${TOFFSET}
    #### MY PERAM FILES FULL NAME IS LIKE cl21_32_64_b6p3_m0p2350_m0p2050-10700_z2_light_peram.11000.T60.peram
    PERAM=${PROJ}/peram/${CFG}/${ENSEM}-${stream}_peram_z${PHASE}_light.${CFG}.T${TOFFSET}.peram
    DUMP=/${run_dir}/${ENSEM}/2pt/phased/${PHASEDIR}/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}
    LOG=${run_dir}/$ENSEM/${ENSEM}-${stream}/out
    XML=${run_dir}/$ENSEM/${ENSEM}-${stream}/xml

    BOP=/qcd/volatile/JLabLQCD/jkarpie/baryon_ops/${ENSEM}_extension/${ENSEM}-${stream}/dbs/$CFG/${ENSEM}-${stream}.n${NVEC}.t0_0.NtFwd_64.baryon.colorvec
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
DB=${OUT}/${ENSEM}.nuc_${OPDISPS}.p${MOMX}${MOMY}${MOMZ}.n${NVEC}.t0_${TOFFSET}.tcorr_${TCORR}
#----------------------------------------------------------------------------------------------------



########################
# GET TO WORK
########################
echo "Doing CFG = $CFG"
# Remove old run dirs; make anew and bump to them
rm -rf ${LOG}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG
mkdir -p ${LOG}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG
 pushd ${LOG}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG

rm ${DB}.sdb$CFG
rm -rf ${DUMP}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG
mkdir -p ${DUMP}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG
#pushd ${DUMP}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG




################################################

# Remove old run dirs; make anew and bump to them
rm -rf ${XML}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG
mkdir -p ${XML}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG

echo PERAM $PERAM
echo BOP $BOP
/qcd/work/JLabLQCD/jkarpie/run_scripts_24s/gluon/2pt/make_redstar_2pt_xml.sh \
	${XML}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG/nucleon_control_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.xml$CFG \
	$MOMX $MOMY $MOMZ $MOMX $MOMY $MOMZ \
	$CFG $TOFFSET \
	$PERAM $BOP ${DB}.sdb$CFG

# Need to fixx placement of thrreads on cores
echo "Running redstar at " `date`

/qcd/work/JLabLQCD/jkarpie/run_scripts_24s/gluon/2pt/run_redstar_int.2pt.no-nodes.sh \
    ${XML}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG/nucleon_control_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.xml$CFG >& ${LOG}/run_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.${CFG}/out.redstar_T${TOFFSET}_p${MOMX}.${MOMY}.${MOMZ}.$CFG

echo "Ending redstar script at time= " `date`

popd

# # Cleanup $DUMP and $LOG
# rm -r ${DUMP}/run$CFG/
# rm -r ${LOG}/run$CFG/


exit 0
