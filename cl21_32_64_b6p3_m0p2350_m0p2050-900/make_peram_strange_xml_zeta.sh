#!/bin/bash

filename=$1
cfg_file=$2
eig_file=$3
prop_file=$4
T=$5
zeta=$6

ssize=32
tsize=64

num_vecs=96
smear_fact=0.08
smear_num=10

cat <<EOF > ${filename}
<?xml version="1.0"?>
<chroma>
 <Param>
  <InlineMeasurements>
    <elem>
      <Name>PROP_AND_MATELEM_DISTILLATION_SUPERB</Name>
      <Frequency>1</Frequency>
      <Param>
        <Contractions>
          <mass_label>S-0.2050</mass_label>
          <num_vecs>$num_vecs</num_vecs>
          <t_sources>$T</t_sources>
          <Nt_forward>64</Nt_forward>
          <Nt_backward>0</Nt_backward>
          <decay_dir>3</decay_dir>
          <num_tries>-1</num_tries>
          <max_rhs>1</max_rhs>
          <phase>0.00 0.00 ${zeta}.00</phase>
        </Contractions>
        <Propagator>
          <version>10</version>
          <quarkSpinType>FULL</quarkSpinType>
          <obsvP>false</obsvP>
          <numRetries>1</numRetries>

          <FermionAction>
            <FermAct>CLOVER</FermAct>
            <Mass>-0.2050</Mass>
            <clovCoeff>1.20536588031793</clovCoeff>
            <AnisoParam>
              <anisoP>false</anisoP>
              <t_dir>3</t_dir>
              <xi_0>1</xi_0>
              <nu>1</nu>
            </AnisoParam>
            <FermState>
              <Name>STOUT_FERM_STATE</Name>
              <rho>0.125</rho>
              <n_smear>1</n_smear>
              <orthog_dir>-1</orthog_dir>
              <FermionBC>
                <FermBC>SIMPLE_FERMBC</FermBC>
                <boundary>1 1 1 -1</boundary>
              </FermionBC>
            </FermState>
          </FermionAction>
           <InvertParam>
               <invType>QUDA_MULTIGRID_CLOVER_INVERTER</invType>
               <CloverParams>
                 <Mass>-0.2050</Mass>
                 <clovCoeff>1.20536588031793</clovCoeff>
                 <AnisoParam>
                   <anisoP>false</anisoP>
                   <t_dir>3</t_dir>
                   <xi_0>1</xi_0>
                   <nu>1</nu>
                 </AnisoParam>
               </CloverParams>
               <RsdTarget>1e-07</RsdTarget>
               <Delta>0.1</Delta>
               <Pipeline>4</Pipeline>
               <MaxIter>500</MaxIter>
               <RsdToleranceFactor>8.0</RsdToleranceFactor>
               <AntiPeriodicT>true</AntiPeriodicT>
               <SolverType>GCR</SolverType>
               <Verbose>true</Verbose>
               <AsymmetricLinop>true</AsymmetricLinop>
               <CudaReconstruct>RECONS_12</CudaReconstruct>
               <CudaSloppyPrecision>SINGLE</CudaSloppyPrecision>
               <CudaSloppyReconstruct>RECONS_8</CudaSloppyReconstruct>
               <AxialGaugeFix>false</AxialGaugeFix>
               <AutotuneDslash>true</AutotuneDslash>
               <MULTIGRIDParams>
                 <Verbosity>true</Verbosity>
                 <Precision>HALF</Precision>
                 <Reconstruct>RECONS_8</Reconstruct>
                 <Blocking>
                   <elem>4 4 4 4</elem>
                   <elem>2 2 2 2</elem>
                 </Blocking>
                 <CoarseSolverType>
                   <elem>GCR</elem>
                   <elem>CA_GCR</elem>
                 </CoarseSolverType>
                 <CoarseResidual>0.1 0.1 0.1</CoarseResidual>
                 <MaxCoarseIterations>12 12 8</MaxCoarseIterations>
                 <RelaxationOmegaMG>1.0 1.0 1.0</RelaxationOmegaMG>
                 <SmootherType>
                   <elem>CA_GCR</elem>
                   <elem>CA_GCR</elem>
                   <elem>CA_GCR</elem>
                 </SmootherType>
                 <SmootherTol>0.25 0.25 0.25</SmootherTol>
                 <NullVectors>24 32</NullVectors>
                 <Pre-SmootherApplications>0 0</Pre-SmootherApplications>
                 <Post-SmootherApplications>8 8</Post-SmootherApplications>
                 <SubspaceSolver>
                   <elem>CG</elem>
                   <elem>CG</elem>
                 </SubspaceSolver>
                 <RsdTargetSubspaceCreate>5e-06 5e-06</RsdTargetSubspaceCreate>
                 <MaxIterSubspaceCreate>500 500</MaxIterSubspaceCreate>
                 <MaxIterSubspaceRefresh>500 500</MaxIterSubspaceRefresh>
                 <OuterGCRNKrylov>20</OuterGCRNKrylov>
                 <PrecondGCRNKrylov>10</PrecondGCRNKrylov>
                 <GenerateNullspace>true</GenerateNullspace>
                 <GenerateAllLevels>true</GenerateAllLevels>
                 <CheckMultigridSetup>false</CheckMultigridSetup>
                 <CycleType>MG_RECURSIVE</CycleType>
                 <SchwarzType>ADDITIVE_SCHWARZ</SchwarzType>
                 <RelaxationOmegaOuter>1.0</RelaxationOmegaOuter>
                 <SetupOnGPU>1 1</SetupOnGPU>
               </MULTIGRIDParams>
               <SubspaceID>mg_subspace</SubspaceID>
               <SolutionCheckP>true</SolutionCheckP>

             </InvertParam>
        </Propagator>
      </Param>
      <NamedObject>
        <gauge_id>default_gauge_field</gauge_id>
        <colorvec_files><elem>${eig_file}</elem></colorvec_files>
        <prop_op_file>${prop_file}</prop_op_file>
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
