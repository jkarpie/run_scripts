#!/bin/bash

num_vecs=$1
filename=$2
cfg_file=$3
eig_file=$4

ssize=32
tsize=64

smear_fact=0.1
smear_num=10

cat <<EOF > ${filename}
<?xml version="1.0"?>
<chroma>
 <Param>
  <InlineMeasurements>
    <elem>
      <Name>CREATE_COLORVECS_SUPERB</Name>
      <Frequency>1</Frequency>
      <Param>
        <num_vecs>$num_vecs</num_vecs>
        <decay_dir>3</decay_dir>
        <write_fingerprint>false</write_fingerprint>
        <LinkSmearing>
          <LinkSmearingType>STOUT_SMEAR</LinkSmearingType>
          <link_smear_fact>${smear_fact}</link_smear_fact>
          <link_smear_num>${smear_num}</link_smear_num>
          <no_smear_dir>3</no_smear_dir>
        </LinkSmearing>
      </Param>
      <NamedObject>
        <gauge_id>default_gauge_field</gauge_id>
        <colorvec_out>${eig_file}</colorvec_out>
      </NamedObject>
    </elem>
  </InlineMeasurements>
  <nrow>$ssize $ssize $ssize $tsize</nrow>
  </Param>
  <RNG>
    <Seed>
      <elem>2551</elem>
      <elem>3189</elem>
      <elem>2855</elem>
      <elem>707</elem>
    </Seed>
  </RNG>
  <Cfg>
    <cfg_type>SCIDAC</cfg_type>
    <cfg_file>${cfg_file}</cfg_file>
    <parallel_io>true</parallel_io>
  </Cfg>
</chroma>
EOF
