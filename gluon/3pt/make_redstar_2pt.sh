#!/bin/bash

xml_name=$1

pfx=$2 ; pfy=$3 ; pfz=$4
pf="$pfx $pfy $pfz"
pix=$5 ; piy=$6 ; piz=$7
pi="$pix $piy $piz"
qx=$((pix-pfx))
qy=$((piy-pfy))
qz=$((piz-pfz))
q="$qx $qy $qz"

nevec=196
cfg=$8
t0=$9
# Find t_origin
TSIZE=64
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
#t_origin=$(( ( $T_INI + $t0 ) % $TSIZE ))
t_origin=$T_INI


prop_db=${10}
bop_db=${11}
glue_db=${12}

output_db=${13}

# Find which irrep the momenta belong to and set their op files and mom_types
pixMom=${pix#-}
piyMom=${piy#-}
pizMom=${piz#-}
piMODMOM="${pixMom}.${piyMom}.${pizMom}"
pfxMom=${pfx#-}
pfyMom=${pfy#-}
pfzMom=${pfz#-}
pfMODMOM="${pfxMom}.${pfyMom}.${pfzMom}"


qxMom=${qx#-}
qyMom=${qy#-}
qzMom=${qz#-}
qMODMOM="${qxMom}.${qyMom}.${qzMom}"

#pixMom=`echo "sqrt(${pix}*${pix})" | bc `
#piyMom=`echo "sqrt(${piy}*${piy})" | bc `
#pizMom=`echo "sqrt(${piz}*${piz})" | bc `
#piMODMOM="${pixMom}.${piyMom}.${pizMom}"
#pfxMom=`echo "sqrt(${pfx}*${pfx})" | bc `
#pfyMom=`echo "sqrt(${pfy}*${pfy})" | bc `
#pfzMom=`echo "sqrt(${pfz}*${pfz})" | bc `
#pfMODMOM="${pfxMom}.${pfyMom}.${pfzMom}"

#qxMom=`echo "sqrt(${qx}*${qx})" | bc `
#qyMom=`echo "sqrt(${qy}*${qy})" | bc `
#qzMom=`echo "sqrt(${qz}*${qz})" | bc `
#qMODMOM="${qxMom}.${qyMom}.${qzMom}"







op_prefix="/global/homes/j/jkarpie/run_scripts/chroma_python/nuc_op_lists/colin_nuc_lists/"
LGpf=''
opi_file=""
# Catch number of zeros in MODMOM string
modmomZeroespf=`echo $pfMODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep 0 | wc -l`
uniqNonZeropf=`echo $pfMODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep -v 0 | sort -u | wc -l`


if [ $modmomZeroespf -eq 3 ] ; then
    LGpf=G1g
    opf_file=${op_prefix}/nucleon.G1g.rest.list
    pf_type="0 0 0"
elif [ $modmomZeroespf -eq 2 ] ; then
    LGpf=D4
    opf_file=${op_prefix}/nucleon.D4E1-H1o2-n00.inflight.list
    pp=`echo  $pfMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0`
    pf_type="${pp//$'\n'/}0 0"
elif [ $modmomZeroespf -eq 1 ] && [ $uniqNonZeropf -eq 1 ] ; then
    LGpf=D2
    opf_file=${op_prefix}/nucleon.D2E-H1o2-nn0.inflight.list
    pp=`echo  $pfMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -r`
    pf_type="${pp//$'\n'/}0"
elif [ $modmomZeroespf -eq 0 ] && [ $uniqNonZeropf -eq 1 ] ; then
    LGpf=D3
    opf_file=${op_prefix}/nucleon.D3E1-H1o2-nnn.inflight.list
    pp=`echo  $pfMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -r`
    pf_type="${pp//$'\n'/}"
elif [ $modmomZeroespf -eq 1 ] && [ $uniqNonZeropf -eq 2 ] ; then
    LGpf=C4mn0
    opf_file=${op_prefix}/nucleon.C4nm0E-H1o2-nm0.inflight.list
    pp=`echo  $pfMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -ur`
    pf_type="${pp//$'\n'/}0"
elif [ $modmomZeroespf -eq 0 ] && [ $uniqNonZeropf -eq 2 ] ; then
    LGpf=C4nnm
    opf_file=${op_prefix}/nucleon.C4nnmE-H1o2-nnm.inflight.list
    pp=`echo  $pfMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort `
    pf_type="${pp//$'\n'/}"
else
    LGpf=C2nmp
    opf_file=${op_prefix}/${LGpf}
fi

LGpi=''
opi_file=""
# Catch number of zeros in MODMOM string
modmomZeroespi=`echo $piMODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep 0 | wc -l`
uniqNonZeropi=`echo $piMODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep -v 0 | sort -u | wc -l`


if [ $modmomZeroespi -eq 3 ] ; then
    LGpi=G1g
    opi_file=${op_prefix}/nucleon.G1g.rest.list
    pi_type="0 0 0"
elif [ $modmomZeroespi -eq 2 ] ; then
    LGpi=D4
    opi_file=${op_prefix}/nucleon.D4E1-H1o2-n00.inflight.list
    pp=`echo  $piMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0`
    pi_type="${pp//$'\n'/}0 0"
elif [ $modmomZeroespi -eq 1 ] && [ $uniqNonZeropi -eq 1 ] ; then
    LGpi=D2
    opi_file=${op_prefix}/nucleon.D2E-H1o2-nn0.inflight.list
    pp=`echo  $piMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -r`
    pi_type="${pp//$'\n'/}0"
elif [ $modmomZeroespi -eq 0 ] && [ $uniqNonZeropi -eq 1 ] ; then
    LGpi=D3
    opi_file=${op_prefix}/nucleon.D3E1-H1o2-nnn.inflight.list
    pp=`echo  $piMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -r`
    pi_type="${pp//$'\n'/}"
elif [ $modmomZeroespi -eq 1 ] && [ $uniqNonZeropi -eq 2 ] ; then
    LGpi=C4mn0
    opi_file=${op_prefix}/nucleon.C4nm0E-H1o2-nm0.inflight.list
    pp=`echo  $piMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -ur`
    pi_type="${pp//$'\n'/}0"
elif [ $modmomZeroespi -eq 0 ] && [ $uniqNonZeropi -eq 2 ] ; then
    LGpi=C4nnm
    opi_file=${op_prefix}/nucleon.C4nnmE-H1o2-nnm.inflight.list
    pp=`echo  $piMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort `
    pi_type="${pp//$'\n'/}"
else
    LGpi=C2nmp
    opi_file=${op_prefix}/${LGpi}
fi


LGq=''
oq_file=""
# Catch number of zeros in MODMOM string
modmomZeroesq=`echo $qMODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep 0 | wc -l`
uniqNonZeroq=`echo $qMODMOM | awk -F'.' '{printf $1"\n"$2"\n"$3"\n"}' | grep -v 0 | sort -u | wc -l`


if [ $modmomZeroesq -eq 3 ] ; then
    LGq=G1g
    q_type="0 0 0"
elif [ $modmomZeroesq -eq 2 ] ; then
    LGq=D4
    pp=`echo  $qMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0`
    q_type="${pp//$'\n'/}0 0"
elif [ $modmomZeroesq -eq 1 ] && [ $uniqNonZeroq -eq 1 ] ; then
    LGq=D2
    pp=`echo  $qMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -r`
    q_type="${pp//$'\n'/}0"
elif [ $modmomZeroesq -eq 0 ] && [ $uniqNonZeroq -eq 1 ] ; then
    LGq=D3
    pp=`echo  $qMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -r`
    q_type="${pp//$'\n'/}"
elif [ $modmomZeroesq -eq 1 ] && [ $uniqNonZeroq -eq 2 ] ; then
    LGq=C4mn0
    pp=`echo  $qMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort -ur`
    q_type="${pp//$'\n'/}0"
elif [ $modmomZeroesq -eq 0 ] && [ $uniqNonZeroq -eq 2 ] ; then
    LGq=C4nnm
    pp=`echo  $qMODMOM | awk -F'.' '{printf $1" \n"$2" \n"$3" \n"}' | grep -v 0 | sort `
    q_type="${pp//$'\n'/}"
else
    LGq=C2nmp
fi
oq_file=${op_prefix}/${LGq}

cat << EOF > $xml_name
<?xml version="1.0"?>
<RedstarNPt>
  <Param>
    <version>12</version>
    <diagnostic_level>5</diagnostic_level>
    <autoIrrepCG>true</autoIrrepCG>
    <rephaseIrrepCG>false</rephaseIrrepCG>
    <Nt_corr>24</Nt_corr>
    <convertUDtoL>true</convertUDtoL>
    <convertUDtoS>false</convertUDtoS>
    <average_1pt_diagrams>true</average_1pt_diagrams>
    <zeroUnsmearedGraphsP>false</zeroUnsmearedGraphsP>
    <t_origin>${t_origin}</t_origin>
    <bc_spec>-1</bc_spec>
    <Layout>
      <lattSize>32 32 32 64</lattSize>
      <decayDir>3</decayDir>
    </Layout>
    <ensemble>cl21_32_64_b6p3_m0p2390_m0p2050</ensemble>
    <NPointList>
EOF

for rf in 1 2 ; do 
for ri in 1 2 ; do 
for opf in `cat $opf_file | awk '{print $1}'` ; do 
for opi in `cat $opi_file | awk '{print $1}'` ; do 

# First the 2pt function
cat <<EOF >> $xml_name
      <elem>
        <NPoint>
          <annotation>Sink</annotation>
          <elem>
           <t_slice>-2</t_slice>
            <Irrep>
              <smearedP>true</smearedP>
              <creation_op>false</creation_op>
              <flavor>
                <twoI>1</twoI>
                <threeY>3</threeY>
                <twoI_z>1</twoI_z>
              </flavor>
              <irmom>
                <mom>$pf</mom>
                <row>$rf</row>
              </irmom>
              <Op>
                <Operators>
                  <elem>
                    <name>${opf}</name>
                    <mom_type>${pf_type}</mom_type>
                  </elem>
                </Operators>
                <CGs>
                </CGs>
              </Op>
            </Irrep>
          </elem>
          <annotation>Source</annotation>
          <elem>
            <t_slice>${t0}</t_slice>
            <Irrep>
              <smearedP>true</smearedP>
              <creation_op>true</creation_op>
              <flavor>
                <twoI>1</twoI>
                <threeY>3</threeY>
                <twoI_z>1</twoI_z>
              </flavor>
              <irmom>
                <mom>$pi</mom>
                <row>$ri</row>
              </irmom>
              <Op>
                <Operators>
                  <elem>
                    <name>${opi}</name>
                    <mom_type>${pi_type}</mom_type>
                  </elem>
                </Operators>
                <CGs>
                </CGs>
              </Op>
            </Irrep>
          </elem>
        </NPoint>
      </elem>
EOF

opsins #NEEDS DEFINING
# Now the 3pt function
for tsink in {0..${TSIZE}}
do
for z in {1..2}
do
for rins in {1..36}
do
cat <<EOF >> $xml_name
      <elem>
        <NPoint>
          <annotation>Sink</annotation>
          <elem>
           <t_slice>-3</t_slice>
            <Irrep>
              <smearedP>true</smearedP>
              <creation_op>false</creation_op>
              <flavor>
                <twoI>1</twoI>
                <threeY>3</threeY>
                <twoI_z>1</twoI_z>
              </flavor>
              <irmom>
                <mom>$pf</mom>
                <row>$rf</row>
              </irmom>
              <Op>
                <Operators>
                  <elem>
                    <name>${opf}</name>
                    <mom_type>${pf_type}</mom_type>
                  </elem>
                </Operators>
                <CGs>
                </CGs>
              </Op>
            </Irrep>
          </elem>
          <annotation>Insertion</annotation>
          <elem>
            <t_slice>-3</t_slice>
            <Irrep>
              <smearedP>false</smearedP>
              <creation_op>false</creation_op>
              <flavor>
                <twoI>0</twoI>
                <threeY>0</threeY>
                <twoI_z>0</twoI_z>
              </flavor>
              <irmom>
                <mom>$q</mom>
                <row>${rins}</row>
              </irmom>
              <Op>
                <Operators>
                  <elem>
                    <name>${opins}</name>
                    <mom_type>${q_type}</mom_type>
                  </elem>
                </Operators>
                <CGs>
                </CGs>
            </Irrep>
          </elem>
          <annotation>Source</annotation>
          <elem>
            <t_slice>${t0}</t_slice>
            <Irrep>
              <smearedP>true</smearedP>
              <creation_op>true</creation_op>
              <flavor>
                <twoI>1</twoI>
                <threeY>3</threeY>
                <twoI_z>1</twoI_z>
              </flavor>
              <irmom>
                <mom>$pi</mom>
                <row>$ri</row>
              </irmom>
              <Op>
                <Operators>
                  <elem>
                    <name>${opi}</name>
                    <mom_type>${pi_type}</mom_type>
                  </elem>
                </Operators>
                <CGs>
                </CGs>
              </Op>
            </Irrep>
          </elem>
        </NPoint>
      </elem>
EOF
done # for rins
done # for z
done # for tsink



done # for opi
done # for opf
done # for ri
done # for rf

cat <<EOF >> $xml_name
    </NPointList>
  </Param>
  <DBFiles>
    <proj_op_xmls>
    </proj_op_xmls>
    <eval_graph_xml>./eval_graph.${cfg}.xml</eval_graph_xml>
    <noneval_graph_xml>./noneval_graph.${cfg}.xml</noneval_graph_xml>
    <corr_graph_bin>./corr_graph.bin${cfg}</corr_graph_bin>
    <corr_graph_xml>./corr_graph.${cfg}.xml</corr_graph_xml>
    <vertex_coeff_xml>./vertex_coeff_xml.${cfg}.xml</vertex_coeff_xml>
    <output_db>${output_db}</output_db>
    <colorvec_smeared_hadron_node_xml>smeared_hadron_node_template.${cfg}.xml</colorvec_smeared_hadron_node_xml>
  </DBFiles>
  <ColorVec>
    <Param>
      <version>1</version>
      <num_vecs>$nevecs</num_vecs>
      <use_derivP>true</use_derivP>
      <use_genprop4>false</use_genprop4>
      <use_FSq>true</use_FSq>
      <fake_data_modeP>false</fake_data_modeP>
      <ensemble>cl21_32_64_b6p3_m0p2390_m0p2050</ensemble>
      <FlavorToMass>
        <elem>
          <flavor>l</flavor>
          <mass>U-0.2390</mass>
        </elem>
        <elem>
          <flavor>s</flavor>
          <mass>U-0.2050</mass>
        </elem>
        <elem>
          <flavor>c</flavor>
          <mass>U0.20</mass>
        </elem>
        <elem>
          <flavor>e</flavor>
          <mass>U0.20</mass>
        </elem>
        <elem>
          <flavor>x</flavor>
          <mass>U0.05</mass>
        </elem>
        <elem>
          <flavor>y</flavor>
          <mass>U0.05</mass>
        </elem>
      </FlavorToMass>
    </Param>
    <DBFiles>
      <prop_dbs>
        <elem>${prop_db}</elem>
      </prop_dbs>
      <smeared_baryon_dbs>
        <elem>${bop_db}</elem>
      </smeared_baryon_dbs>
      <smeared_meson_dbs>
      </smeared_meson_dbs>
      <smeared_glue_dbs>
      </smeared_glue_dbs>
      <smeared_tetra_dbs>
      </smeared_tetra_dbs>
      <unsmeared_meson_dbs>
      </unsmeared_meson_dbs>
      <unsmeared_genprop4_dbs>
      </unsmeared_genprop4_dbs>
      <twoquark_discoblock_dbs>
      </twoquark_discoblock_dbs>
      <hadron2pt_discoblock_dbs>
      </hadron2pt_discoblock_dbs>
      <fsq_discoblock_dbs>
        <elem>${glue_db}</elem>
      </fsq_discoblock_dbs>
    </DBFiles>
  </ColorVec>
</RedstarNPt>
EOF

