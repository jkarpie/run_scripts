#!/bin/bash


here="/qcd/work/JLabLQCD/jkarpie/run_scripts_24s/gluon/2pt"

T=$1

px=$2
py=$3
pz=$4

cfg=$5
phase=$6
stream=$7



conj_px=` echo -1*$px | bc `
conj_py=` echo -1*$py | bc `
conj_pz=` echo -1*$pz | bc `

for TT in `seq ${T} $((T+7))`
do
  ${here}/npt.sh $TT $px $py $pz $cfg $phase $stream
  ${here}/npt.sh $TT $conj_px $conj_py $conj_pz $cfg $phase $stream
done
