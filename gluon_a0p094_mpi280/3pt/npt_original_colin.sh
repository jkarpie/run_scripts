#!/bin/bash

ExeDir=`pwd`
# source /home1/06377/tg856768/builds/xsede/frontera/scalar_had-node-libs/env_frontera_scalar.sh


#################
# GLOBAL PARAMS
#################
export ENSEM=cl21_32_64_b6p3_m0p2350_m0p2050
export BETA=b6p3
export PROJ=/scratch3/projects/phy20014/isoClover/${BETA}/${ENSEM}
TSIZE=64
NVEC=64
#-------------------------------------------------------------------

#################################
# SWITCHES
#################################
OPDISPS='all'
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
T_INI=`/home1/06377/tg856768/RUNS/set_tsrc.pl $CFG $TSIZE | awk '{printf $6"\n"}'`
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
if [ $LG == G1g ]; then
    # nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.G1g.rest.single.list
    nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.G1g.rest.list
    # nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.G1g.rest.single.row2.list
elif [ $LG == D4 ]; then
    # nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.D4E1-H1o2-n00.inflight.single.list
    nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.D4E1-H1o2-n00.inflight.list
elif [ $LG == D2 ]; then
    nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.D2E-H1o2-nn0.inflight.list
elif [ $LG == D3 ]; then
    nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.D3E1-H1o2-nnn.inflight.list
elif [ $LG == C4mn0 ]; then
    nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.C4nm0E-H1o2-nm0.inflight.list
elif [ $LG == C4nnm ]; then
    nucOps=/home1/06377/tg856768/RUNS/nuc_2pt/nucleon.C4nnmE-H1o2-nnm.inflight.list
else
    echo "Don't yet have an operator list for $LG!"
    exit 33
fi
#--------------------------------------------------------------------------------------------------




########################
# I/Os
########################
CFGPREF_CHR="/work2/06377/tg856768/frontera/isoClover/${BETA}/${ENSEM}/cfgs/${ENSEM}_cfg"
CVEC=${PROJ}/eigs_mod/${ENSEM}.3d.eigs
LOG=''; OUT=''
if [ $PHASE == '0.00' ]; then
    PERAM=/work2/06377/tg856768/frontera/isoClover/${BETA}/${ENSEM}/prop_db/${ENSEM}.prop.n${NVEC}.light.t0_${TOFFSET}
    DUMP=/tmp/${USER}/nuc_runs/${ENSEM}/2pt/unphased/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}
    LOG=/scratch3/06377/tg856768/nuc_runs/${ENSEM}/2pt/unphased

    BOP=${DUMP}/run${CFG}/${ENSEM}.n${NVEC}.t0_${TOFFSET}.NtFwd_${NT_FWD}.baryon.colorvec
    OUT=${PROJ}/2ptcorrs/unphased
else
    # d001_2.00 phased perambulators apparently have 96 evecs stored for toffset=0,16
    NVECTMP=$NVEC
    if [[ ( $TOFFSET -eq 0 || $TOFFSET -eq 16 ) && $PHASE == '2.00' ]]; then NVECTMP=96; fi

    PERAM=${PROJ}/phased/prop_db/d001_${PHASE}/${ENSEM}.phased_${PHASE}.prop.n${NVECTMP}.light.t0_${TOFFSET}
    DUMP=/tmp/${USER}/nuc_runs/${ENSEM}/2pt/phased/${PHASEDIR}/t0_${TOFFSET}/momXYZ.${MOMX}.${MOMY}.${MOMZ}
    LOG=/scratch3/06377/tg856768/nuc_runs/${ENSEM}/2pt/phased/${PHASEDIR}

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
rsync -L ${PERAM}.sdb${CFG} ${DUMP}/run${CFG}/
rsync -L ${CVEC}.mod$CFG ${DUMP}/run${CFG}/
# Now modify the prefixes to be passed
CVEC=${DUMP}/run${CFG}/${ENSEM}.3d.eigs
if [ $PHASE == '0.00' ]; then
    PERAM=${DUMP}/run${CFG}/${ENSEM}.prop.n${NVEC}.light.t0_${TOFFSET}
else
    PERAM=${DUMP}/run${CFG}/`echo $PERAM | awk -F'/' '{printf $NF"\n"}'`
#${ENSEM}.phased_d001_${PHASE}.prop.n${NVEC}.light.t0_${TOFFSET}
fi
#--------------------------------------------------------------------------------------------------




PYDIR=/home1/06377/tg856768/chroma_python

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

$PYDIR/baryon_elem.py -c $CFG -e $ENSEM -g $CFGPREF_CHR -n $NVEC \
    -t $T_ORIGIN -T $NT_FWD -v $CVEC -m ${MOM}/${CONJMOM} -b ${BOP}.sdb$CFG -d $OPDISPS \
    --gaugeSmear --smearFact=$SFACT --smearNum=$SNUM \
    --superb --phase "0.0 0.0 $PHASE" > bop_xmls/$XMLI
# --haromOptimize > bop_xmls/$XMLI


export OMP_NUM_THREADS=1

CHROMA="/work/06873/eloy/frontera/chromaform/install-gnu/chroma-mgproto-qphix-avx512/bin/chroma"
CHROMA_EX="-by 4 -bz 4 -pxy 0 -pxyz 0 -c $OMP_NUM_THREADS -sy 1 -sz 1 -minct 1"
GEOM="-geom 2 4 4 1"

/usr/local/bin/ibrun -n 32 $CHROMA $CHROMA_EX $GEOM -i bop_xmls/$XMLI >& ${LOG}/run${CFG}/BOP${CFG}

#---------------------------------------------------------------------------------------------------




export NPT_BATCH_SIZE=1
export KMP_AFFINITY=scatter,granularity=fine

echo "Setting up the input files for redstar"    
#########################
# XMLS FOR THIS OPERATOR
#########################
${PYDIR}/redstar_2pt.py -c $CFG -e $ENSEM -i $nucOps -f $nucOps \
    -p $MOM -r $TCORR -t $T_ORIGIN \
    -s 0 -n "smeared_hadron_node" -u "unsmeared_hadron_node" -o $DB \
    -y "baryon_2pt" -g "." -x 0 --no_writing_nodes \
    --nvecs=$NVEC --prop_db_prefix=$PERAM -b $BOP -v 12 >> nucleon_control.xml$CFG


export OMP_NUM_THREADS=56
echo "Running redstar at " `date`

# source /home1/06377/tg856768/builds/xsede/frontera/scalar_had-node-libs_rge/env_frontera_scalar.sh
source /home1/06377/tg856768/builds/xsede/frontera/scalar_devel/env_frontera_scalar.sh

/home1/06377/tg856768/RUNS/run_redstar_int.2pt.no-nodes.sh \
    nucleon_control.xml$CFG >& ${LOG}/run${CFG}/DB$CFG

echo "Ending redstar script at time= " `date`

popd

# # Cleanup $DUMP and $LOG
# rm -r ${DUMP}/run$CFG/
# rm -r ${LOG}/run$CFG/


exit 0
