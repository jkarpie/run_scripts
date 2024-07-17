#!/bin/bash

xml_name=$1
px=$2
py=$3
pz=$4
phase=$5
eig_file=$6
cfg_file=$7
output_file=$8

rm $xml_name

conj_px=` echo -1*$px | bc `
conj_py=` echo -1*$py | bc `
conj_pz=` echo -1*$pz | bc `

cat << EOF >> $xml_name
<?xml version="1.0"?>
<chroma>
  <Param>
    <InlineMeasurements>
      <elem>
        <Name>BARYON_MATELEM_COLORVEC_SUPERB</Name>
        <Frequency>1</Frequency>
        <Param>
          <num_vecs>64</num_vecs>
          <t_source>0</t_source>
          <Nt_forward>64</Nt_forward>
          <phase>0.0 0.0 ${phase}</phase>
          <mom_list>
	<elem>$px $py $pz</elem>
	<elem>$conj_px $conj_py $conj_pz</elem>
          </mom_list>
          <decay_dir>3</decay_dir>
          <use_derivP>true</use_derivP>
          <displacement_list>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>0</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>1</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>2</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>3</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>1 1</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>2 2</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>3 3</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>1 2</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>1 3</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>2 1</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>2 3</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>3 1</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>0</middle>
              <right>3 2</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>1</middle>
              <right>1</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>1</middle>
              <right>2</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>1</middle>
              <right>3</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>2</middle>
              <right>2</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>2</middle>
              <right>3</right>
            </elem>
            <elem>
              <left>0</left>
              <middle>3</middle>
              <right>3</right>
            </elem>
          </displacement_list>
          <max_tslices_in_contraction>8</max_tslices_in_contraction>
          <max_moms_in_contraction>4</max_moms_in_contraction>
          <max_vecs>64</max_vecs>
          <use_superb_format>true</use_superb_format>
          <LinkSmearing>
            <LinkSmearingType>STOUT_SMEAR</LinkSmearingType>
            <link_smear_fact>0.1</link_smear_fact>
            <link_smear_num>10</link_smear_num>
            <no_smear_dir>3</no_smear_dir>
          </LinkSmearing>
        </Param>
        <NamedObject>
          <gauge_id>default_gauge_field</gauge_id>
          <colorvec_files>
            <elem>${eig_file}</elem>
          </colorvec_files>
          <baryon_op_file>${output_file}</baryon_op_file>
        </NamedObject>
      </elem>
    </InlineMeasurements>
    <nrow>32 32 32 64</nrow>
  </Param>
  <RNG>
    <Seed>
      <elem>11</elem>
      <elem>11</elem>
      <elem>11</elem>
      <elem>0</elem>
    </Seed>
  </RNG>
  <Cfg>
    <cfg_type>SZINQIO</cfg_type>
    <cfg_file>${cfg_file}</cfg_file>
  </Cfg>
</chroma>
EOF
