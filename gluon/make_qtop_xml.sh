#!/bin/bash
filename=$1
cfg_file=$2
cfg=$3

cat <<EOF > ${filename}
<chroma>
<RNG>
  <Seed>
    <elem>13342</elem>
    <elem>21342</elem>
    <elem>24511</elem>
    <elem>8116</elem>
  </Seed>
</RNG>

<Cfg>
 <cfg_type>SZINQIO</cfg_type>
 <cfg_file>${cfg_file}</cfg_file>
</Cfg>

<Param>
  <InlineMeasurements>
    <elem>
        <Name>WILSON_FLOW</Name>
        <Frequency>1</Frequency>
        <Param>
          <version>1</version>
          <nstep>100</nstep>
          <wtime>3.5</wtime>
          <t_dir>3</t_dir>
        </Param>
        <NamedObject>
          <gauge_in>default_gauge_field</gauge_in>
          <gauge_out>wflow</gauge_out>
        </NamedObject>
        <xml_file>flow_${cfg}.xml</xml_file>
      </elem>
      <elem>
        <Name>QTOP_NAIVE</Name>
        <Frequency>1</Frequency>
        <Param>
          <version>1</version>
          <k5>0</k5>
        </Param>
        <NamedObject>
          <gauge_id>wflow</gauge_id>
        </NamedObject>
      </elem>
      <elem>
        <Name>ERASE_NAMED_OBJECT</Name>
        <Frequency>1</Frequency>
        <NamedObject>
          <object_id>wflow</object_id>
        </NamedObject>
      </elem>
  </InlineMeasurements>

  <nrow>64 64 64 192</nrow>
</Param>
</chroma>
EOF
