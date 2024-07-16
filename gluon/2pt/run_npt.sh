#!/bin/bash


here=`pwd`

T=$1
pz_max=$2
cfg=$3
phase=$4
stream=$5

for TT in {${T}..$((T+7))}
do
  ${here}/npt.sh $TT 0 0 0 $cfg $phase $stream
  ${here}/npt.sh $TT 0 1 0 $cfg $phase $stream
  ${here}/npt.sh $TT 0 -1 0 $cfg $phase $stream
for pz in {1..${pz_max}} 
do

  ${here}/npt.sh $TT 0 0 $pz $cfg $phase $stream
  ${here}/npt.sh $TT 0 0 -$pz $cfg $phase $stream
  ${here}/npt.sh $TT 0 1 $pz $cfg $phase $stream
  ${here}/npt.sh $TT 0 -1 -$pz $cfg $phase $stream
  ${here}/npt.sh $TT 0 1 -$pz $cfg $phase $stream
  ${here}/npt.sh $TT 0 -1 $pz $cfg $phase $stream

done
done
