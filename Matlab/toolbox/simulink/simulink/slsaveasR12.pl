#! /usr/local/bin/perl
###################################
#
# Saves an R13 mdl file into R12.1 or R12 mdl format 
# Usage:
# 
#    slsaveas [r13model] [r12.1model] [saveAsVersion]
# 
# Copyright 1990-2004 The MathWorks, Inc.
#
# $Revision: 1.7.4.2 $

 #Initialize GLOBAL VARIABLES
 @FilePosFixPtSumBlocks  =  ();
 @FilePosFixPtGainBlocks = ();
 @FilePosFixPtLookupBlocks = (); 
 @FilePosFixPtProductBlocks = ();
 @FilePosFixPtUnitDelayBlocks = ();
 @FilePosFixPtAbsBlocks = ();
 @FilePosFixPtSignumBlocks = (); 
 @FilePosFixPtLogicBlocks = (); 
 @FilePosFixPtSwitchBlocks = (); 
 @FilePosFixPtMultiPortSwitchBlocks = (); 
 @FilePosFixPtRelayBlocks = ();
 @FilePosFixPtConstantBlocks = ();
 @FilePosFixPtRelationalOperatorBlocks = ();
 @FilePosRateTransitionVector = ();
 @FilePosModelVerification = (); 
 @FilePosFixPtLookup2DBlocks  = (); 

 #Input parameters
 ($infilename, $outfilename, $tempFileName, $SaveAsVersion) = @ARGV;

 GetFileBlocksPosVector($infilename);

 #Get the Systems parameters to be filtered from the model
 @sysParam = GetSysParams();


UpdateModel($infilename, $outfilename,$SaveAsVersion);

sub UpdateModel
{
  ($mdl_IN,$mdl_OUT,$SaveAsVersion) =  @_;

  open(IN, "<$mdl_IN") || die "Unable to open $mdl_IN";
  open(OUT,">$mdl_OUT") || die "Unable to create $mdl_OUT. Please check the directory permission\n";
  my($blkFlag);
  my($libFlag); 
  
  #Define library names
  if ( $SaveAsVersion =~ /\bsaveasr12\b/ ) {
    # SaveAsR12
    $sumLibName  = "fixpt3/FixPt\\nSum";
    $gainLibName = "fixpt3/FixPt\\nGain";
    $productLibName = "fixpt3/FixPt\\nProduct";
    $delayLibName = "fixpt3/FixPt\\nUnit Delay";
    $absLibName = "fixpt3/FixPt\\nAbs";
    $signLibName = "fixpt3/FixPt\\nSign";
    $switchLibName = "fixpt3/FixPt\\nSwitch";
    $mswitchLibName = "fixpt3/FixPt\\nMultiPort\\nSwitch";
    $relayLibName = "fixpt3/FixPt\\nRelay";
    $constantLibName = "fixpt3/FixPt\\nConstant";
    $relOperatorLibName = "fixpt3/FixPt\\nRelational\\nOperator";
    $logOperatorLibName = "fixpt3/FixPt\\nLogical\\nOperator";
    $lookupLibName = "fixpt3/FixPt\\nLook-Up\\nTable";
    $lookup2DLibName = "fixpt3/FixPt\\nLook-Up\\nTable (2-D)";
  } else {
    # SaveAsR12PointOne
    $sumLibName  = "fixpt_lib_3p1/Math/Sum";
    $gainLibName = "fixpt_lib_3p1/Math/Gain";
    $productLibName = "fixpt_lib_3p1/Math/Product";
    $delayLibName = "fixpt_lib_3p1/Delays & Holds/Unit Delay";
    $absLibName = "fixpt_lib_3p1/Math/Abs";
    $signLibName = "fixpt_lib_3p1/Nonlinear/Sign";
    $switchLibName = "fixpt_lib_3p1/Select/Switch";
    $mswitchLibName = "fixpt_lib_3p1/Select/MultiPort\\nSwitch";
    $relayLibName = "fixpt_lib_3p1/Nonlinear/Relay";
    $constantLibName = "fixpt_lib_3p1/Sources/Constant";
    $relOperatorLibName = "fixpt_lib_3p1/Logic & Comparison/Relational\\nOperator";
    $logOperatorLibName = "fixpt_lib_3p1/Logic & Comparison/Logical\\nOperator";
    $lookupLibName = "fixpt_lib_3p1/LookUp/Look-Up\\nTable";
    $lookup2DLibName = "fixpt_lib_3p1/LookUp/Look-Up\\nTable (2-D)";
  }
 while (<IN>) {  
   #Initialize local variables
   my($line) = $_;
   chomp($line); 
   my($dontPrint) = 0;
   my($dontPrintParam) = 0;
   my($donPrintProductParam1) = 0;
   my($donPrintProductParam2) = 0;
   my($donPrintProductParam3) = 0;
   my($LinearAnalysisInputParam) = 0;
   my($LinearAnalysisOutputParam) =0;
   my($OutputAfterFinalValueParam) = 0;
   my($BusSelectionModeParam) = 0;
   my($InputPortOffsetsParam) = 0;
   my($ProbeSignalDimensionsParam) = 0;
   my($MaskToolTipStringParam) = 0;
   my($MaskVariableAliasesParam) =0;
     

   #Renaming the Port Dimensions to port width blocks
   if($blkFlag){
     if(/\s*BlockType\s*Inport/../\s*\}\s*$/){
       next if /LatchInput/;
     }
   }
   
   if(/\s*Tag\s*\"FixPtSumSaveAsR12\"\s*$/) {
     $posSumFixpt = $.-2;
   }
  #########################################
  # Link Sum blocks to fixed point Library#
  #########################################
  foreach $FilePosFixPtBlks  (@FilePosFixPtSumBlocks){

     if($. == $FilePosFixPtBlks+8){
	$dontPrintInputs = 1;
     }

    #Sum Block
    if(/\s*BlockType\s*Sum/../\s*\}\s*$/){     
      if($. == ($FilePosFixPtBlks-2)) {
        # "BlockType Sum" gets replaced by  "BlockType Reference"
	s/Sum/Reference/g; 
      }

      if(/\s*Tag\s*\"FixPtSumSaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}
	if(/Position/) {
	  print OUT "      SourceBlock	      \"$sumLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Sum\"\n";
	}
        # Handle different parameters name 
	s/Inputs/listofsigns/g; 

	if( $line =~ /IconShape/) {
	  s/IconShape//g; 
	  s/\"rectangular\"//g; 
	}
	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
	if( $line =~ /InputSameDT/) {
	  s/InputSameDT//g;
	  s/on//g;
	  s/off//g;
	}
	if( $line =~ /OutDataTypeMode/) {
          s/All ports same datatype/Inherit via back propagation/;
          s/Same as first input/Inherit via internal rule/;
	  s/OutDataTypeMode/OutputDataTypeScalingMode/g;
	}

	next if /OutDataTypeMode/;
	next if /Inputs/;	
	next if /IconShape/;
	next if /ShowAdditionalParam/;
      }
    }  #end of BlockType Sum ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtSumSaveAsR12\"\s*$/) {
     next;
    }

  if(/\s*BlockType\s*Sum/../\s*\}\s*$/){
    next if /ShowAdditionalParam/;
    next if /OutputDataTypeScalingMode/;
    next if /OutDataType/;
    next if /OutDataTypeMode/;
    next if /OutScaling/;
    next if /LockScale/;
    next if /RndMeth/;
    next if /ShowAdditionalParam/;
    next if /InputSameDT/;

  }

  #########################################
  # Link Gain blocks to fixed point Library#
  #########################################
  foreach $FilePosFixPtBlks  (@FilePosFixPtGainBlocks){

    #Gain Block
    if(/\s*BlockType\s*Gain/../\s*\}\s*$/){     
      if($. == ($FilePosFixPtBlks-2)) {
        # "BlockType Gain" gets replaced by  "BlockType Reference"
	s/Gain/Reference/g; 
      }

      if(/\s*Tag\s*\"FixPtGainSaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}
	if(/Position/) {
	  print OUT "      Ports                  [1, 1]\n";
	  print OUT "      SourceBlock	      \"$gainLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Gain\"\n";
	}
        # Handle different parameters name 
	s/\bGain\b/gainval/g; 
	s/\bParameterDataType\b/GainDataType/g; 
	s/\bParameterScalingMode\b/VecRadixGroup/g;
	s/\bParameterScaling\b/GainScaling/g;

	if( $line =~ /Multiplication/) {
	    s/Multiplication/ElevsMatrix/g; 
	}
	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}

	if( $line =~ /ParameterDataTypeMode/) {
          s/Same as input/Inherit via internal rule/;
	  s/ParameterDataTypeMode/GainDataTypeScalingMode/g;
	}

	if( $line =~ /OutDataTypeMode/) {
          s/Same as input/Inherit via internal rule/;
	  s/OutDataTypeMode/OutputDataTypeScalingMode/g;
	}

      }
    }  #end of BlockType Gain ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtGainSaveAsR12\"\s*$/) {
     next;
    }

  if(/\s*BlockType\s*Gain/../\s*\}\s*$/){
    # Rename 
    #  ... Multiplication  "Matrix(K*u) (u vector)"...
    # to
    #  ... Multiplication  "Matrix(K*u)"...
    if( $line =~ /Multiplication/) {
      s/\(u vector\)//g;      
    }
    next if /ShowAdditionalParam/;
    next if /OutDataType/;
    next if /LockScale/;
    next if /RndMeth/;
    next if /ShowAdditionalParam/;
    next if /ParameterDataTypeMode/;
    next if /ParameterDataType/;
    next if /ParameterScaling/;
    next if /ParameterScalingMode/;
    next if /OutScaling/;
  }



  #########################################
  # Link Lookup blocks to fixed point Library#
  #########################################
  foreach $FilePosFixPtBlks  (@FilePosFixPtLookupBlocks){

    #Lookup Block
    if(/\s*BlockType\s*Lookup/../\s*\}\s*$/){     
      if($. == ($FilePosFixPtBlks-2)) {
        # "BlockType Lookup" gets replaced by  "BlockType Reference"
	s/Lookup/Reference/g; 
      }

      if(/\s*Tag\s*\"FixPtLookupSaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}
	if(/Position/) {
	  print OUT "      Ports               [1, 1]\n";
	  print OUT "      SourceBlock	      \"$lookupLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Lookup\"\n";
	}
        # Handle different parameters name 
	s/InputValues/XLookUpData/g;
	s/OutputValues/YLookUpData/g;

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
	if( $line =~ /InputSameDT/) {
	  s/InputSameDT//g;
	  s/on//g;
	  s/off//g;
	}

	if( $line =~ /OutDataTypeMode/) {
          s/All ports same datatype/Inherit via back propagation/;
          s/Same as input/Inherit via internal rule/;
	  s/OutDataTypeMode/OutputDataTypeScalingMode/g;
	}

	next if /OutDataTypeMode/;
	next if /Inputs/;	
	next if /IconShape/;
	next if /ShowAdditionalParam/;
      }
    }  #end of BlockType Lookup ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtLookupSaveAsR12\"\s*$/) {
     next;
    }

  if(/\s*BlockType\s*Lookup\b/../\s*\}\s*$/){
    next if /ShowAdditionalParam/;
    next if /OutputDataTypeScalingMode/;
    next if /OutDataType/;
    next if /OutDataTypeMode/;
    next if /OutScaling/;
    next if /LockScale/;
    next if /RndMeth/;
    next if /InputSameDT/;
    next if /SaturateOnIntegerOverflow/;
    next if /LookUpMeth/;

  }


  #########################################
  # Link Lookup2D blocks to fixed point Library#
  #########################################
  foreach $FilePosFixPtBlks  (@FilePosFixPtLookup2DBlocks){

    #Lookup2D Block
    if(/\s*BlockType\s*Lookup2D/../\s*\}\s*$/){     
      if($. == ($FilePosFixPtBlks-2)) {
        # "BlockType Lookup2D" gets replaced by  "BlockType Reference"
	s/Lookup2D/Reference/g; 
      }

      if(/\s*Tag\s*\"FixPtLookup2DSaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}
	if(/Position/) {
	  print OUT "      Ports               [2, 1]\n";
	  print OUT "      SourceBlock	      \"$lookup2DLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Look-Up Table (2-D)\"\n";
	}
        # Handle different parameters name 
	s/RowIndex/RowLookUpData/g;
	s/ColumnIndex/ColLookUpData/g;
	s/OutputValues/TableLookUpData/g;

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
	if( $line =~ /InputSameDT/) {
	  s/InputSameDT//g;
	  s/on//g;
	  s/off//g;
	}

	if( $line =~ /OutDataTypeMode/) {
          s/All ports same datatype/Inherit via back propagation/;
          s/Same as input/Inherit via internal rule/;
	  s/OutDataTypeMode/OutputDataTypeScalingMode/g;
	}

	next if /OutDataTypeMode/;
	next if /Inputs/;	
	next if /IconShape/;
	next if /ShowAdditionalParam/;
      }
    }  #end of BlockType Lookup2D ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtLookup2DSaveAsR12\"\s*$/) {
     next;
   }
   if(/\s*BlockType\s*Lookup2D\b/../\s*\}\s*$/){
    next if /ShowAdditionalParam/; 
    next if /OutputDataTypeScalingMode/;
    next if /OutDataType/; 
    next if /OutDataTypeMode/;
    next if /OutScaling/; 
    next if /LockScale/; 
    next if /RndMeth/; 
    next if /InputSameDT/; 
    next if /SaturateOnIntegerOverflow/;
    next if /LookUpMeth/; 

  }

  #############################################
  # Link Product blocks to fixed point Library#
  #############################################
  foreach $FilePosProductFixPtBlks  (@FilePosFixPtProductBlocks){

    #Product Block
    if(/\s*BlockType\s*Product/../\s*\}\s*$/){     
      if($. == ($FilePosProductFixPtBlks-2)) {
	s/Product/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtProductSaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}

	if(/Position/) {
	  print OUT "      SourceBlock	      \"$productLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Product\"\n";
	}
	s/Inputs/listofops/g; 

	
	# Handle different parameters name 
	if( $line =~ /Multiplication/) {
	  s/Multiplication/ElevsMatrix/g; 
	}
	if( $line =~ /InputSameDT/) {
	  s/InputSameDT//g;
	  s/on//g;
	  s/off//g;
	}
	if( $line =~ /OutDataTypeMode/) {
          s/Same as first input/Inherit via internal rule/;
	  s/OutDataTypeMode/OutputDataTypeScalingMode/g;
	}
	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
      }
    }  #end of BlockType Product ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtProductSaveAsR12\"\s*$/) {
     next;
    }

  if(/\s*BlockType\s*Product/../\s*\}\s*$/){
    next if /ShowAdditionalParam/;
    next if /OutputDataTypeScalingMode/;
    next if /OutDataType/;
    next if /OutScaling/;
    next if /LockScale/;
    next if /RndMeth/;
    next if /ShowAdditionalParam/;
    next if /InputSameDT/;
  }

  ##############################################
  # Link UnitDelay blocks to fixed point Library#
  #############################################
  foreach $FilePosUnitDelayFixPtBlks  (@FilePosFixPtUnitDelayBlocks){

    #UnitDelay Block
    if(/\s*BlockType\s*UnitDelay/../\s*\}\s*$/){     
      if($. == ($FilePosUnitDelayFixPtBlks-2)) {
	s/UnitDelay/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtUnitDelaySaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}

	if(/Position/) {
	  print OUT "      Ports               [1, 1]\n";
	  print OUT "      SourceBlock	      \"$delayLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Unit Delay\"\n";
	}
	# Handle different parameters name 
	s/X0/vinit/g; 
	s/SampleTime/samptime/g; 

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
      }
    }  #end of BlockType UnitDelay ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtUnitDelaySaveAsR12\"\s*$/) {
     next;
   }

  ##############################################
  # Link Abs blocks to fixed point Library     #
  ##############################################
  foreach $FilePosAbsFixPtBlks  (@FilePosFixPtAbsBlocks){

    #Abs Block
    if(/\s*BlockType\s*Abs/../\s*\}\s*$/){     
      if($. == ($FilePosAbsFixPtBlks-2)) {
	s/Abs/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtAbsSaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}

	if(/Position/) {
	  print OUT "      Ports               [1, 1]\n";
	  print OUT "      SourceBlock	      \"$absLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Absolute Value\"\n";
	}
	s/SaturateOnIntegerOverflow/DoSatur/g; 

      }
    }  #end of BlockType Abs ...}       
   } #end of for each ...}       
   if(/\s*Tag\s*\"FixPtAbsSaveAsR12\"\s*$/) {
     next;
   }

  ##############################################
  # Link Signum blocks to fixed point Library  #
  ##############################################
  foreach $FilePosSignumFixPtBlks  (@FilePosFixPtSignumBlocks){

    #Signum Block
    if(/\s*BlockType\s*Signum/../\s*\}\s*$/){     
      if($. == ($FilePosSignumFixPtBlks-2)) {
	s/Signum/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtSignumSaveAsR12\"/../\s*\}\s*$/){
	if(/Position/) {
	  print OUT "      Ports               [1, 1]\n";
	  print OUT "      SourceBlock	      \"$signLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Signum\"\n";
	}
      }
    }  #end of BlockType Signum ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtSignumSaveAsR12\"\s*$/) {
     next;
    }

  ##############################################
  # Link Logic blocks to fixed point Library   #
  ##############################################
  foreach $FilePosLogicFixPtBlks  (@FilePosFixPtLogicBlocks){

    #Logic Block
    if(/\s*BlockType\s*Logic/../\s*\}\s*$/){     
      if($. == ($FilePosLogicFixPtBlks-2)) {
	s/Logic/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtLogicSaveAsR12\"/../\s*\}\s*$/){

	if(/Position/) {
	  print OUT "      SourceBlock	      \"$logOperatorLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Logical Operator\"\n";
	}

	s/Operator/logicop/g; 
	s/Inputs/NumInputPorts/g; 
	
	if( $line =~ /OutDataTypeMode/) {
	  s/OutDataTypeMode//;
	  s/\"Specify via dialog\"//g;
	  s/All ports boolean//g;
	  next;
	}

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	  next;
	}
	if( $line =~ /AllPortsSameDT/) {
	  s/AllPortsSameDT//g;
	  s/on//g;
	  s/off//g;
	  next;
	}

      }

    }  #end of BlockType Logic ...}       
   } #end of for each ...}       
   if(/\s*Tag\s*\"FixPtLogicSaveAsR12\"\s*$/) {
     next;
   }

 if(/\s*BlockType\s*Logic/../\s*\}\s*$/){
   if( $line =~ /OutputDataTypeScalingMode/) {
     s/OutputDataTypeScalingMode//;
     s/Specify via dialog//g;
     s/All ports boolean//g;
     next;
   }
   if(/OutDataTypeMode/../rs/){
     next;
   }
   next if /AllPortsSameDT/;
   next if /LogicDataType/;
   next if /ShowAdditionalParam/;
   next if /OutDataTypeMode/;
 }

  ##############################################
  # Link Switch blocks to fixed point Library  #
  ##############################################
  foreach $FilePosSwitchFixPtBlks  (@FilePosFixPtSwitchBlocks){

    #Switch Block
    if(/\s*BlockType\s*Switch/../\s*\}\s*$/){     
      if($. == ($FilePosSwitchFixPtBlks-2)) {
	s/Switch/Reference/g;
      }

      if(/SaturateOnIntegerOverflow/) {  
	s/SaturateOnIntegerOverflow//g;  
	s/off//g;
	s/on//g;
      }

      if(/\s*Tag\s*\"FixPtSwitchSaveAsR12\"/../\s*\}\s*$/){

	if(/Position/) {
          print OUT "      Ports	      [3, 1]\n";
	  print OUT "      SourceBlock	      \"$switchLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Switch\"\n";
	}
	if(!($line =~ /Criteria/) ) {
	s/Threshold/vthresh/g; 
      }
	if( $line =~ /OutDataTypeMode/) {
	  s/OutDataTypeMode/OutputDataTypeScalingMode/;
	  s/All ports same datatype/Inherit via back propagation/;
	  next;
	}

	if( $line =~ /InputSameDT/) {
	  s/InputSameDT//g;
	  s/on//g;
	  s/off//g;
	}

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
      }

    }  #end of BlockType Switch ...}       
   } #end of for each ...}       

 if(/\s*BlockType\s*Switch/../\s*\}\s*$/){
   if( $line =~ /InputSameDT/) {
       s/InputSameDT//g;
       s/on//g;
       s/off//g;
     }
   if( $line =~ /OutDataTypeMode/) {
     s/OutDataTypeMode/OutputDataTypeScalingMode/;
     s/All ports same datatype//g;
     s/Inherit via back propagation//g;
     next;
   }
 if(/Criteria/) {  
    s/Criteria//g;  
    s/u2 >= Threshold//g;  
    s/u2 > Threshold//g;  
    s/u2 ~= 0//g;  
  }
  if(/SaturateOnIntegerOverflow/) {  
    s/SaturateOnIntegerOverflow//g;  
    s/off//g;
    s/on//g;
  }
   next if /RndMeth/;
   next if /ShowAdditionalParam/;
 }

   if(/\s*Tag\s*\"FixPtSwitchSaveAsR12\"\s*$/) {
     next;
    }


  ######################################################
  # Link MultiPortSwitch blocks to fixed point Library #
  ######################################################
  foreach $FilePosMultiPortSwitchFixPtBlks  (@FilePosFixPtMultiPortSwitchBlocks){

    #MultiPortSwitch Block
    if(/\s*BlockType\s*MultiPortSwitch/../\s*\}\s*$/){     
      if($. == ($FilePosMultiPortSwitchFixPtBlks-2)) {
	s/MultiPortSwitch/Reference/g;
      }

      if(/SaturateOnIntegerOverflow/) {  
	s/SaturateOnIntegerOverflow//g;  
	s/off//g;
	s/on//g;
      }

      if(/\s*Tag\s*\"FixPtMultiPortSwitchSaveAsR12\"/../\s*\}\s*$/){
	s/Inputs/NumInputPorts/g; 
	if(/Position/) {
	  print OUT "      SourceBlock	      \"$mswitchLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point  Multi Port Switch\"\n";
	}

	if( $line =~ /OutDataTypeMode/) {
	  s/OutDataTypeMode/OutputDataTypeScalingMode/g;
	  s/All ports same datatype/Inherit via back propagation/;
	}

	if( $line =~ /InputSameDT/) {
	  s/InputSameDT//g;
	  s/on//g;
	  s/off//g;
	}

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
      }

    }  #end of BlockType MultiPortSwitch ...}       
   } #end of for each ...}       

 if(/\s*BlockType\s*MultiPortSwitch/../\s*\}\s*$/){
   if( $line =~ /InputSameDT/) {
     s/InputSameDT//g;
     s/on//g;
     s/off//g;
   }
   if( $line =~ /OutDataTypeMode/) {
     s/OutDataTypeMode//g;
     s/All ports same datatype//g;
     s/Inherit via back propagation//g;
     next;
   }

  if(/SaturateOnIntegerOverflow/) {  
    s/SaturateOnIntegerOverflow//g;  
    s/off//g;
    s/on//g;
  }
   next if /zeroidx/;
   next if /RndMeth/;
   next if /ShowAdditionalParam/;
 }

   if(/\s*Tag\s*\"FixPtMultiPortSwitchSaveAsR12\"\s*$/) {
     next;
    }

  ##############################################
  # Link Relay blocks to fixed point Library     #
  ##############################################
  foreach $FilePosRelayFixPtBlks  (@FilePosFixPtRelayBlocks){

    #Relay Block
    if(/\s*BlockType\s*Relay/../\s*\}\s*$/){     
      if($. == ($FilePosRelayFixPtBlks-2)) {
	s/Relay/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtRelaySaveAsR12\"/../\s*\}\s*$/){
	if(/SaturateOnIntegerOverflow/) {  
	  s/SaturateOnIntegerOverflow//g;  
	  s/off//g;
	  s/on//g;
	}
	if( $line =~ /OutputDataTypeScalingMode/) {
	  s/All ports same datatype/Inherit via back propagation/;
	}
	if(/Position/) {
	  print OUT "      Ports               [1, 1]\n";
	  print OUT "      SourceBlock	      \"$relayLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Relay\"\n";
	}

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}

      }
    }  #end of BlockType Relay ...}       
   } #end of for each ...}       

   if(/\s*Tag\s*\"FixPtRelaySaveAsR12\"\s*$/) {
     next;
   }

 if(/\s*BlockType\s*Relay/../\s*\}\s*$/){
    next if /OutputDataTypeScalingMode/;
    next if /OutDataType/;
    next if /OutScaling/;
    next if /ConRadixGroup/;
    next if /ShowAdditionalParam/;
  }

  ##############################################
  # Link Constant blocks to fixed point Library     #
  ##############################################
  foreach $FilePosConstantFixPtBlks  (@FilePosFixPtConstantBlocks){

    #Constant Block
    if(/\s*BlockType\s*Constant/../\s*\}\s*$/){     
      if($. == ($FilePosConstantFixPtBlks-2)) {
	s/Constant/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtConstantSaveAsR12\"/../\s*\}\s*$/){
	s/VectorParams1D/VectInt/g;
	s/Value/constval/g;
	if(/Position/) {
	  print OUT "      Ports                   [0, 1]\n";
	  print OUT "      SourceBlock	      \"$constantLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Constant\"\n";
	}

	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}
	if( $line =~ /OutDataTypeMode/) {
	  s/Inherit from \'Constant value\'/Inherit via back propagation/;
	  s/OutDataTypeMode/OutputDataTypeScalingMode/g;
	}
      }
    }  #end of BlockType Constant ...}       
   } #end of for each ...}       

 if(/\s*BlockType\s*Constant/../\s*\}\s*$/){
    next if /OutputDataTypeScalingMode/;
    next if /OutDataType/;
    next if /OutScaling/;
    next if /ConRadixGroup/;
    next if /ShowAdditionalParam/;
    next if /OutDataTypeMode/;
  }
   if(/\s*Tag\s*\"FixPtConstantSaveAsR12\"\s*$/) {
     next;
   }


  ############################################################
  # Link RelationalOperator blocks to fixed point Library    #
  ############################################################
  foreach $FilePosRelationalOperatorFixPtBlks  (@FilePosFixPtRelationalOperatorBlocks){

    #RelationalOperator Block
    if(/\s*BlockType\s*RelationalOperator/../\s*\}\s*$/){     
      if($. == ($FilePosRelationalOperatorFixPtBlks-2)) {
	s/RelationalOperator/Reference/g;
      }

      if(/\s*Tag\s*\"FixPtRelationalOperatorSaveAsR12\"/../\s*\}\s*$/){
	s/Operator/relop/g; 
	if(/Position/) {
	  print OUT "      Ports                 [2, 1]\n";
	  print OUT "      SourceBlock	      \"$relOperatorLibName\"\n";
	  print OUT "      SourceType	      \"Fixed-Point Relational Operator\"\n";
	}


	if( $line =~ /ShowAdditionalParam/) {
	  s/ShowAdditionalParam//g;
	  s/on//g;
	  s/off//g;
	}

	if( $line =~ /InputSameDT/) {
	  s/InputSameDT//g;
	  s/on//g;
	  s/off//g;
	}

	if( $line =~ /LogicOutDataTypeMode/) {
	  s/LogicOutDataTypeMode//;
	  s/Specify via dialog//g;
	  s/Input ports same datatype, output boolean//g;
	  next;
	}

      }
    }  #end of BlockType RelationalOperator ...}       
   } #end of for each ...}       


   if(/\s*BlockType\s*RelationalOperator/../\s*\}\s*$/){
     if( $line =~ /InputSameDT/) {
       s/InputSameDT//g;
       s/on//g;
       s/off//g;
     }
     if(/LogicOutDataTypeMode/../rs/){
       next;
     }
     next if /ShowAdditionalParam/;
     next if /LogicDataType/;
     next if /LogicOutDataTypeMode/;
     s/LogicOutDataTypeMode//;
     s/Specify via dialog//g;
     s/Input ports same datatype, output boolean//g;
     next if /\" boolean\"/;
     next if /\"oolean\"/;
     next if /\"an\"/;
   }
   if(/\s*Tag\s*\"FixPtRelationalrelopSaveAsR12\"\s*$/) {
     next;
   }

  ############################
  #Removing  block parameters#
  ############################

  #Removing ZeroCross from zerocrossing blocks
   if($blkFlag){
      next if /ZeroCross/;
      next if /MaskVarAliasString/;
      # remaping the Signal Specification, Look-Up blocks, Manual Switch, Reshape, Dot Product
      # Slider Gain and Matrix Concatenation
      if(/\s*SourceBlock\s+\"simulink\//){
	s/\"simulink\/Signal\\nRouting\/Manual/\"simulink3\/Nonlinear\/Manual/g;
	s/\"simulink\/Look-Up\\nTables/\"simulink3\/Functions\\n\& Tables/g;
	s/\"simulink\/Discontinuities/\"simulink3\/Nonlinear/g;
	s/\"simulink\/Ports \&\\nSubsystems/\"simulink3\/Signals\\n\& Systems/g;
	s/\"simulink\/Math\\nOperations\/Reshape/\"simulink3\/Signals\\n\& Systems\/Reshape/g;
	s/\"simulink\/Math\\nOperations\/Dot Product/\"simulink3\/Math\/Dot Product/g;
	s/\"simulink\/Math\\nOperations\/Slider/\"simulink3\/Math\/Slider/g;
	s/\"simulink\/Math\\nOperations\/Matrix/\"simulink3\/Signals\\n\& Systems\/Matrix/g;
	s/\"simulink\/Math\\nOperations\/Algebraic/\"simulink3\/Math\/Algebraic/g;
	s/\"simulink\/Math\\nOperations\/Polynomial/\"simulink3\/Functions\\n\& Tables\/Polynomial/g;
	s/\"simulink\/Math\\nOperations\/Bitwise/\"simulink3\/Math\/Bitwise/g;
	s/\"simulink\/Model-Wide\\nUtilities\/Model Info/\"simulink3\/Signals\\n\& Systems\/Model Info/g;
      }
      if(/\s*SourceBlock\s+\"simulink\/Signal\\nAttributes\/Signal.*/){
	s/\"simulink\/Signal\\nAttributes/\"simulink3\/Signals\\n\& Systems/g;
      }
      # Remove callbacks for the Signal Builder Block
      next if /CopyFcn\s+\"sigbuilder_block\(.*/;
      next if /CloseFcn\s+\"sigbuilder_block\(.*/;
      next if /DeleteFcn\s+\"sigbuilder_block\(.*/;
      next if /StartFcn\s+\"sigbuilder_block\(.*/;
      next if /StopFcn\s+\"sigbuilder_block\(.*/;
      next if /NameChangeFcn\s+\"sigbuilder_block\(.*/;
      next if /ClipboardFcn\s+\"sigbuilder_block\(.*/;
      next if /OpenFcn\s+\"sigbuilder_block\(.*/;
      next if /CloseFcn\s+\"sigbuilder_block\(.*/;
    }
   if(/\s*BlockType\s*Reference/../\s*\}/){
     if(/\s*Name\s.*/../\s*\}/) {
       s/DataType\s+\"Specify via dialog\"//g;
       next if /OutDataType/;
       next if /OutScaling/;
       next if /SamplingMode/;
     }
   }

  #Set RTWSystem code to Function if code resuse is selected
  if(/\s*BlockType\s*SubSystem/../\s*\}/){
    if ($line =~ /RTWSystemCode/) {
      s/\"Reusable function\"/\"Function\"/g;
    }
   }

   # Fix Annotations
   if(/\s*Annotation \{/../\s*\}/) { 
     s/Name/Text/g;
     next if /FontText/g;
   }
   if(/\s*BlockType\s*Assertion/../\s*\}/){
     next if /Enabled/;
     next if /StopWhenAssertionFail/;
   }
   if(/\s*BlockType\s*Inport/../\s*\}/){
     next if /ShowAdditionalParam/;
     next if /OutDataType/;
     next if /OutScaling/;
     if ($line =~ /\bDataType\b/) {
       s/Specify via dialog/auto/;
     }
   }
   #Removing parameter for the UnitDelay
   if($blkFlag){
   if(/\s*BlockType\s*UnitDelay/../\s*\}/){
     next if /RTWStateStorageClass/;
     next if /RTWSystemCode/;
   }
 }
   #Renaming parameters from the Sine block
   if(/\s*BlockType\s*Sin/../\s*\}\s*$/){
     s/Time based/Time-based/g;
     s/Sample based/Sample-based/g;
   }

  #Renaming parameters from the Pulse Generator block
   if(/\s*BlockType\s*DiscretePulseGenerator/../\s*\}\s*$/){
     s/Time based/Time-based/g;
     s/Sample based/Sample-based/g;
   }

   #Removing parameters for the scope block
   if(/\s*BlockType\s*Scope/../\s*\}\s*$/){
     next if /Visible/;
     next if /ModelBased/;
   }

  if($blkFlag){
    next if /RTWStateStorageClass/;
    next if /UserDataPersistent/;
  }
   #Removing parameters for the Demux block
   if(/\s*BlockType\s*Demux/../\s*\}\s*$/){
     next if /DisplayOption/;
   }

   #Removing  parameters from the RateLimiter block
   if(/\s*BlockType\s*RateLimiter/../\s*\}\s*$/){
     next if /LinearizeAsGain/;
   }

   #Removing  parameters from the FromWorkspace block
   if(/\s*BlockType\s*FromWorkspace/../\s*\}\s*$/){
     next if /SigBuilderData/;
   }

  #Removing  parameters from the FromWorkspace block
   if(/\s*BlockType\s*Width/../\s*\}\s*$/){
     next if /ShowAdditionalParam/;
     next if /OutputDataTypeScalingMode/;
     next if /DataType/;
   }

  ####################################################
  #Replacing Assertion block with an empty subsystem #
  ####################################################
  if($blkFlag){
     if(/\s*BlockType\s*Assertion/.../\s*\}\s*$/){

       #Make the "Assertion" block a subsystem 
       if(/\s*BlockType\s*Assertion/){
	 s/Assertion/SubSystem/g;
       }
       if($line =~ /\s*Name\s+\"/){ 
	 $AssertionblkName =  substr($line, index($line,"\""), rindex($line,"\""));
       }
       if(/Position/) {
	  print OUT "      Ports               [1, 0]\n";
	}
       if($line =~ /\s*Ports\s*/){ 
	 $AssertionInputNumPorts =  substr($line, index($line,"[") + 1, 1);
         $AssertionOutputNumPorts =  substr($line, index($line,",") + 2, 1);
       }

       $AssertionSubSystem = CreateSubsystem( $AssertionblkName, 1,0);
       if($line =~ /\}/){
	 $replacemtLineAssertionBlock = $.;
       }
     }
  }
  if($replacemtLineAssertionBlock == $. ) {
     print OUT  "$AssertionSubSystem\n";
  }

 ######################################################
 #Replacing the RateTransition block with an Empty Subsystem #
 ######################################################
   foreach $FilePosRateTransition  (@FilePosRateTransitionVector){
   #Determine the file position for ports, BlockType, and BlockName
   #so that input ports, outports, block name, block type can be determined.
   if($. == $FilePosRateTransition-7){
    if($line =~ /\s*BlockType\s*/){
     $posPorts = $.+ 2;
     $posBlockType = $.;
     $posBlockName = $.+ 1;
     }
    }
    if($. == $FilePosRateTransition-6){
     if($line =~ /\s*BlockType\s*/){
      $posPorts = $.+ 2;
      $posBlockType = $.;
      $posBlockName = $.+ 1;
   }
    elsif($line =~ /\}/){ 
     $posPorts = $.+4;
     $posBlockType = $.+2;
     $posBlockName = $.+ 3;
     }
    elsif($line =~ /\s*Block {/){ 
     $posPorts = $.+3;
     $posBlockType = $.+1;
     $posBlockName = $.+ 2;
    }
   }
   if($. == $FilePosRateTransition-4){
     if($line =~ /\s*BlockType\s*/){
       $posPorts = $.+ 2;
       $posBlockType = $.;
       $posBlockName = $.+ 1;
     }
   }
  #Determine blockname
   if($. == $posBlockName) {
     $RateTransitionBlockName= substr($line, index($line,"\""), rindex($line,"\""));
    }
  #Make the Referece block a subsystem 
  if($. == $posBlockType){
      s/Reference/SubSystem/g; 
    }

    $RateTransitionSubSystem = CreateSubsystem($RateTransitionBlockName, 1, 1);

   if($. == $FilePosRateTransition){
      s/\s*SourceBlock\s+\"simulink\/Signal\\nAttributes\/Rate.*$/$RateTransitionSubSystem/g;
    }
   if(/\s*SourceType\s*\"Rate_Transition\"/../\s*\}\s*$/){
     push(@LinesToRemoveRateTransition,$.);  
    }
  }

  if($. == pop(@LinesToRemoveRateTransition)){ 
    next if /SourceType/;
    next if /DataIntegrity/;
    next if /DeterministicTransfer/;
    next if /TransitionType/;
    next if /InitCond/;
  }



 #################################################################
 #Replacing the ModelVerification blocks with an Empty Subsystem #
 #################################################################
foreach $FilePosModelVerification  (@FilePosModelVerification)
  {
    #Determine the file position for ports, BlockType, and BlockName
    #so that input ports, outports, block name, block type can be determined.
    if($. == $FilePosModelVerification-7)
      {
	if($line =~ /\s*BlockType\s*/){
	  $posPorts = $.+ 2;
	  $posBlockType = $.;
	  $posBlockName = $.+ 1;
	}
      }
    if($. == $FilePosModelVerification-6)
      {
	if($line =~ /\s*BlockType\s*/){
	  $posPorts = $.+ 2;
	  $posBlockType = $.;
	  $posBlockName = $.+ 1;
	} 
	elsif($line =~ /\}/) { 
	  $posPorts = $.+4;
	  $posBlockType = $.+2;
	  $posBlockName = $.+ 3;
	} elsif($line =~ /\s*Block {/){ 
	  $posPorts = $.+3;
	  $posBlockType = $.+1;
	  $posBlockName = $.+ 2;
	}
     }
   if($. == $FilePosModelVerification-4){
     if($line =~ /\s*BlockType\s*/){
       $posPorts = $.+ 2;
       $posBlockType = $.;
       $posBlockName = $.+ 1;
     }
   }
  #Determine blockname
  if($. == $posBlockName) {
     $ModelVerificationBlockName= substr($line, index($line,"\""), rindex($line,"\""));
  }
  #Make the Referece block a subsystem 
  if($. == $posBlockType){
      s/Reference/SubSystem/g; 
  }

  #Determine the number of ports
  if($. == $posPorts ){
     $ModelVerificationInputNumPorts =  substr($line, index($line,"[") + 1, 1);
     $ModelVerificationOutputNumPorts =  substr($line, index($line,",") + 2, 1);
   }

    $ModelVerificationSubSystem = CreateSubsystem($ModelVerificationBlockName, 
						  $ModelVerificationInputNumPorts,
						  $ModelVerificationOutputNumPorts);

   if($. == $FilePosModelVerification){
      s/\s*SourceBlock\s+\"simulink\/Model\\nVerification.*/$ModelVerificationSubSystem/g;
    }
   @SourceTypeModelVerificationBlocks = ("Checks_DGap",
					 "Checks_DRange",
					 "Checks_SGap",
					 "Checks_SRange",
					 "Checks_DMin",
					 "Checks_DMax",
					 "Checks_SMin",
					 "Checks_SMax");

   foreach $blksSourceType (@SourceTypeModelVerificationBlocks) {
     if(/\s*SourceType\s*\"$blksSourceType\"/.../\s*\}\s*$/){
       push(@LinesToRemoveModelVerification,$.);  
     }
   }
  }
  if($. == pop(@LinesToRemoveModelVerification)){ 
    next if /SourceType/;
    next if /stopWhenAssertionFail/;
    next if /export/;
    next if /max_included/;
    next if /min_included/;
  }



   if($blkFlag){
     if(/\s*BlockType\s*Inport/../\s*\}\s*$/){
       next if /SamplingMode/;
     }
   }



################################################################
# R12.1 Only Items --- BEGIN HERE                                #
################################################################
   if ( $SaveAsVersion =~ /\bsaveasr12pointone\b/ ) {
     if(/\s*Port {/../\s*\}/){
       next if /DataLogging/;
       next if /DataLoggingNameMode/;
       next if /DataLoggingDecimateData/;
       next if /DataLoggingDecimation/;
       next if /DataLoggingLimitDataPoints/;
       next if /DataLoggingMaxPoints/;
     }
   }

################################################################
# R12 Only Items --- BEGIN HERE                                #
################################################################
if ( $SaveAsVersion =~ /\bsaveasr12\b/ ) {
   #########################
   #Reconstruct Port Arrays
   #########################
   
   #Flow control blocks
   if($line =~ /s*Ports\s*\[\d+\,\s\d+\,\s\d+,\s\d+\,\s\d+,\s\d+,\s\d+,\s\d+/){
     s/,\s\d+,\s\d+,\s\d+\]/\]/g;
   }
   

   #Renaming the Port Dimensions to port width blocks
   if($blkFlag){
     if(/\s*BlockType\s*Inport/../\s*\}\s*$/){
       next if /LatchInput/;
       next if /SamplingMode/;
     }
   }

   #Removing  parameters from the Sine block
   if(/\s*BlockType\s*Sin/../\s*\}\s*$/){
     next if /SineType/;
     next if /Bias/;
     next if /Samples/;
     next if /Offset/;
   }

   #Removing BusCreatorMode  parameter from Mux
   if($blkFlag){
     if(/\s*BlockType\s*Mux/../\s*\}/){
       next if /BusCreatorMode/;
     }
   }
   #Removing parameter for the DiscretePulseGenerator
   if($blkFlag){
     if(/\s*BlockType\s*DiscretePulseGenerator/../\s*\}/){
       next if /PulseType/;
     }
   }
   #Removing parameter for the UnitDelay
   if($blkFlag){
     if(/\s*BlockType\s*UnitDelay/../\s*\}/){
       next if /RTWStateStorageClass/;
     }
   }
   
   #Removing  RTWStateStorageClass and LinearizeMemory block
   if( (/\s*BlockType\s*Memory/ ||
	/\s*BlockType\s*DiscreteTransferFcn/ ||
	/\s*BlockType\s*DiscreteZeroPole/ ||
	/\s*BlockType\s*DiscreteStateSpace/ ||
	/\s*BlockType\s*DiscreteIntegrator/ ||
	/\s*BlockType\s*DataStoreMemory/ ||
	/\s*BlockType\s*DiscreteFilter/ ) ...
	/\s*\}\s*$/ ){
      next if /RTWStateStorageClass/;
      next if /LinearizeMemory/;
    }

   #Removing TransDelayFeedthrough for Transport and Variable Delay block
   if($blkFlag){
     if((/\s*BlockType\s*TransportDelay/ || 
	 /\s*BlockType\s*VariableTransportDelay/) .. 
	 /\s*\}\s*$/) {
       next if /TransDelayFeedthrough/;
     }
   }
   
   # Remove selected signals from the Scope block
   if(/\s*ListType\s*SelectedSignals/){
     next;
   }

   #Removing  parameters from the S-function Block
   if(/\s*BlockType\s*\"S\-Function\"/../\s*\}\s*$/){
     next if /WizardData/;
     next if /AncestorBlock/;
     next if /\"\\nBuilder/;
     next if /OpenFcn\s*\"sfunctionwizard\(gcbh\)\"/;
   }
   
   #Removing  parameters from the Sine block
   if(/\s*BlockType\s*Sin/../\s*\}\s*$/){
     next if /SineType/;
     next if /Bias/;
     next if /Samples/;
     next if /Offset/;
   }



   #Removing Port info:
   # Port {
   #	PortNumber		1
   # 	Name			"locked"
   #	TestPoint		off
   #	LinearAnalysisOutput	off
   #	LinearAnalysisInput	off
   #	RTWStorageClass		"Auto"
   #     }
   if(/\s*Port {/../\s*\}/){
     next;
   }


      next if /\bAuto\b\s*$/;
      #Removing UserDataPersistent parameter
      if($blkFlag){
	next if /RTWStateStorageClass/;
	next if /UserDataPersistent/;
      }
      # Remap Data Type conversion blocks to FixPt Lib
      if(/\s*fixpt_lib_3p1/){
	s/fixpt_lib_3p1\/Data Type\//fixpt3\/FixPt\\n/g;
      }

      ##################################################### 
      #Replcaing BusCreator block with an empty subsystem #
      #####################################################   
      if($blkFlag){
	if(/\s*BlockType\s*BusCreator/.../\s*\}\s*$/){

	  #Make the "BusCreator" block a subsystem 
	  if(/\s*BlockType\s*BusCreator/){
	    s/BusCreator/SubSystem/g;
	  }
	  if($line =~ /\s*Name\s+\"/){ 
	    $BusCreatorblkName =  substr($line, index($line,"\""), rindex($line,"\""));
	  }
	  if($line =~ /\s*Ports\s*/){ 
	    $BusCreatorInputNumPorts =  substr($line, index($line,"[") + 1, 1);
	    $BusCreatorOutputNumPorts =  substr($line, index($line,",") + 2, 1);
	  }

	  if($BusCreatorInputNumPorts > 0 && $BusCreatorOutputNumPorts > 0){
	    $BusCreatorSubSystem = CreateSubsystem( $BusCreatorblkName, $BusCreatorInputNumPorts, 
					            $BusCreatorOutputNumPorts);
	  }
	  if($line =~ /\}/){
	    $replacemtLineBusCreatorBlock = $.;
	  }
	  next if /Inputs/;
	  next if /DisplayOption/;
	}
      }
      if($replacemtLineBusCreatorBlock == $. ) {
	print OUT  "$BusCreatorSubSystem\n";
      }

      ##################################################### 
      #Replcaing Assignment block with an empty subsystem #
      #####################################################  
      if($blkFlag){
	if(/\s*BlockType\s*Assignment/.../\s*\}\s*$/){

	  #Make the "Assignment" block a subsystem 
	  if(/\s*BlockType\s*Assignment/){
	    s/Assignment/SubSystem/g;
	  }
	  if($line =~ /\s*Name\s*/){ 
	    $ActionPortAssignmentblkName =  substr($line, index($line,"\""), rindex($line,"\""));
	  }
	  if($line =~ /\s*Ports\s*/){ 
	    $ActionPortAssignmentInputNumPorts =  substr($line, index($line,"[") + 1, 1);
	    $ActionPortAssignmentOutputNumPorts =  substr($line, index($line,",") + 2, 1);
	  }
	  if($line =~ /\s*Position\s*/){ 
	    # $position = $.;
	  }
	  if($ActionPortAssignmentInputNumPorts > 0 && $ActionPortAssignmentOutputNumPorts > 0){
	    $ActionAssignmentSubSystem = CreateSubsystem($ActionPortAssignmentblkName, $ActionPortAssignmentInputNumPorts, 
							 $ActionPortAssignmentOutputNumPorts);
	  }

	  if($line =~ /\}/){
	    $replacemtLineAssignmentBlock = $.;
	  }
	  next if /InputType/;
	  next if /ElementSrc/;
	  next if /Elements/;
	  next if /RowSrc/;
	  next if /Rows/;
	  next if /ColumnSrc/;
	  next if /Columns/;
	}
      }
      if($replacemtLineAssignmentBlock == $. ) {
	print OUT  "$ActionAssignmentSubSystem\n";
      }


      ############################################# 
      #Replcaing If block with an empty subsystem #
      #############################################   
      if($blkFlag){
	if(/\s*BlockType\s*If/.../\s*\}\s*$/){
	  #Make the "If" block a subsystem 
	  if(/\s*BlockType\s*If/){
	    s/If/SubSystem/g;
	  }
	  if($line =~ /\s*Name\s*/){ 
	    $ActionPortIfblkName =  substr($line, index($line,"\""), rindex($line,"\""));
	  }
	  if($line =~ /\s*Ports\s*/){ 
	    $ActionPortIfInputNumPorts =  substr($line, index($line,"[") + 1, 1);
	    $ActionPortIfOutputNumPorts =  substr($line, index($line,",") + 2, 1);
	  }
	  if($ActionPortIfInputNumPorts > 0 && $ActionPortIfOutputNumPorts > 0){
	    $ActionIfSubSystem = CreateSubsystem($ActionPortIfblkName, $ActionPortIfInputNumPorts, 
						 $ActionPortIfOutputNumPorts);
	  }
	  
	  if($line =~ /\}/){
	    $replacemtLineIfBlock = $.;
	  }
	  next if /NumInputs/;
	  next if /IfExpression/;
	  next if /ShowElse/;
	}
      }
      if($replacemtLineIfBlock == $. ) {
	print OUT  "$ActionIfSubSystem\n";
      }
      


      ##################################################### 
      #Replacing ActionPort block with an empty subsystem #
      #####################################################   
      if($blkFlag){
	if(/\s*BlockType\s*ActionPort/.../\s*\}\s*$/){
	  
	  #Make the "ActionPort" block a subsystem 
	  if(/\s*BlockType\s*ActionPort/){
	    s/ActionPort/EnablePort/g;
	  }
	  if($line =~ /\s*Name\s*/){ 
	    $ActionPortblkName =  substr($line, index($line,"\""), rindex($line,"\""));
	  }
	  if($line =~ /\s*Ports\s*/){ 
	    $ActionPortInputNumPorts =  substr($line, index($line,"[") + 1, 1);
	    $ActionPortOutputNumPorts =  substr($line, index($line,",") + 2, 1);
	  }
	  if($line =~ /\s*Position\s*/){ 
	    $position = $.+1;
	    
	  }
	  
	  $EnableInfoTags = "\t Ports                [0, 0, 0, 0, 0]\n\t ShowOutputPort	     off";
	  if($position == $. ){
	    print OUT "$EnableInfoTags";
	  }
	  
	  if($ActionPortInputNumPorts > 0 && $ActionPortOutputNumPorts > 0){
	    $ActionSubSystem = CreateSubsystem($ActionPortblkName, $ActionPortInputNumPorts, 
					       $ActionPortOutputNumPorts);
	  }
	  
	  if($line =~ /\}/){
	    $replacemtLineActionBlock = $.;
	  }
	  next if /InitializeStates/;
	  next if /ActionType/;
	}
      }
      if(/\s*Line {\s*/.../\s*\}/){
	s/DstPort\s*ifaction/DstPort\s\t\tenable/g;      
      }
	 
	 if($replacemtLineActionBlock == $. ) {
	   print OUT  "$ActionSubSystem\n";
	 }


	 ##################################################### 
	 #Replacing SwitchCase block with an empty subsystem #
	 #####################################################   
	 if($blkFlag){
	   if(/\s*BlockType\s*SwitchCase/.../\s*\}\s*$/){

	     #Make the "SwitchCase" block a subsystem 
	     if(/\s*BlockType\s*SwitchCase/){
	       s/SwitchCase/SubSystem/g;
	     }
	     if($line =~ /\s*Name\s*/){ 
	       $SwitchCaseblkName =  substr($line, index($line,"\""), rindex($line,"\""));
	     }
	     if($line =~ /\s*Ports\s*/){ 
	       $SwitchCaseInputNumPorts =  substr($line, index($line,"[") + 1, 1);
	       $SwitchCaseOutputNumPorts =  substr($line, index($line,",") + 2, 1);
	     }
	     if($line =~ /\s*Position\s*/){ 
	       $position = $.+1;
	     }
	     
	     $EnableInfoTags = "\t Ports                [0, 0, 0, 0, 0]\n";
	     if($position == $. ){
	       print OUT "$EnableInfoTags";
	     }

	     if($SwitchCaseInputNumPorts > 0 && $SwitchCaseOutputNumPorts > 0){
	       $SwitchCaseSubSystem = CreateSubsystem($SwitchCaseblkName, $SwitchCaseInputNumPorts, 
						      $SwitchCaseOutputNumPorts);
	     }

	     if($line =~ /\}/){
	       $replacemtLineSwitchCaseBlock = $.;
	     }

	     next if /CaseConditions/;
	     next if /CaseShowDefault/;
	   }
	 }
	 if(/\s*Line {\s*/.../\s*\}/){
	   s/DstPort\s*ifaction/DstPort\s\t\tenable/g;      
	 }

	    if($replacemtLineSwitchCaseBlock == $. ) {
	      print OUT  "$SwitchCaseSubSystem\n";
	    }

	    
	    ######################################################### 
	    #Replacing WhileIterator block with an empty subsystem  #
	    #########################################################   
	    if($blkFlag){
	      if(/\s*BlockType\s*WhileIterator/.../\s*\}\s*$/){

		#Make the "WhileIterator" block a subsystem 
		if(/\s*BlockType\s*WhileIterator/){
		  s/WhileIterator/SubSystem/g;
		}
		if($line =~ /\s*Name\s*/){ 
		  $WhileIteratorblkName =  substr($line, index($line,"\""), rindex($line,"\""));
		}
		if($line =~ /\s*Ports\s*/){ 
		  $WhileIteratorInputNumPorts =  substr($line, index($line,"[") + 1, 1);
		  $WhileIteratorOutputNumPorts =  substr($line, index($line,",") + 2, 1);
		}

		if($WhileIteratorInputNumPorts > 0 && $WhileIteratorOutputNumPorts > 0){
		  $WhileIteratorSubSystem = CreateSubsystem($WhileIteratorblkName, $WhileIteratorInputNumPorts, 
							    $WhileIteratorOutputNumPorts);
		}

		if($line =~ /\}/){
		  $replacemtLineWhileIteratorBlock = $.;
		}

		next if /MaxIters/;
		next if /WhileBlockType/;
		next if /ResetStates/;
		next if /ShowIterationPort/;
		next if /OutputDataType/;

	      }
	    }

	    if($replacemtLineWhileIteratorBlock == $. ) {
	      print OUT  "$WhileIteratorSubSystem\n";
	    }

	    ######################################################### 
	    #Replacing ForIterator block with an empty subsystem  #
	    #########################################################   
	    if($blkFlag){
	      if(/\s*BlockType\s*ForIterator/.../\s*\}\s*$/){

		#Make the "ForIterator" block a subsystem 
		if(/\s*BlockType\s*ForIterator/){
		  s/ForIterator/SubSystem/g;
		}
		if($line =~ /\s*Name\s*/){ 
		  $ForIteratorblkName =  substr($line, index($line,"\""), rindex($line,"\""));
		}
		if($line =~ /\s*Ports\s*/){ 
		  $ForIteratorInputNumPorts =  substr($line, index($line,"[") + 1, 1);
		  $ForIteratorOutputNumPorts =  substr($line, index($line,",") + 2, 1);
		}

		if($ForIteratorInputNumPorts > 0 && $ForIteratorOutputNumPorts > 0){
		  $ForIteratorSubSystem = CreateSubsystem($ForIteratorblkName, $ForIteratorInputNumPorts, 
							  $ForIteratorOutputNumPorts);
		}

		if($line =~ /\}/){
		  $replacemtLineForIteratorBlock = $.;
		}

		next if /ResetStates/;
		next if /IterationSource/;
		next if /NumIters/;
		next if /ShowIterationPort/;
		next if /OutputDataType/;
	      }
	    }

	    if($replacemtLineForIteratorBlock == $. ) {
	      print OUT  "$ForIteratorSubSystem\n";
	    }

} # endif /SaveAsR12/
 
  
################################################################
# R12 Only Items --- END HERE                                  #
################################################################

   if($mdlFlagParam || $libFlag){
    #Removing model parameters
     foreach $pvString (@sysParam) {
       if ( $line =~ /$pvString/) {
          $dontPrint = 1;
          last;
       }
    }   
   next if $dontPrint;
   }

  ######################################### 
  # Create a flag for a block definition  #
  ######################################### 
  if($line =~ /s*Block {\s*$/){ 
      $blkFlag = 1;
    }

     if($line =~ /s*Model {\s*$/../\s*\}\s*$/) { 
       if($line =~ /\sName\s*\"*\"/) { 
	 ($var0, $var1) = /(\w+)\s+(.*)/;
	 $tempFileName =~ s/(\.\w+)//g; 
	 s/$var1/\"$tempFileName\"/g;
       }
       
       #Rename Version String
       if($line =~ /s*Version\s*5.0/){
	 s/5.0/4.0/g;
       }
       if($line =~ /s*Version\s*5.1/){
	 s/5.1/4.0/g;
       }
     }
	
   # Create a flag for model parameters
   if($line =~ /s*Model {\s*$/){ 
      $mdlFlagParam = 1;
    }

   # Create a flag for a library definition  
   if($line =~ /s*Library {\s*$/){ 
      $libFlag = 1;
    }

      if($line =~ /s*Block {\s*$/){ 
	$blkFlag = 1;
      }
	 
   print OUT $_;
  }
  close(IN);
  close(OUT);
}


sub GetSysParams {

@string = ("TryForcingSFcnDF",
           "ShowStorageClass",
	   "ExecutionOrder",
	   "InvalidFcnCallConnMsg",
           "CovMetricSettings",
	   "ExtModeAutoUpdateStatusClock",
           "ExtModeSkipDownloadWhenConnect",
	   "RTWExpressionDepthLimit",
	   "ShowLoopsOnError",
	   "IgnoreBidirectionalLines",
	   "covSaveCumulativeToWorkspaceVar",
	   "CovSaveSingleToWorkspaceVar",
	   "CovCumulativeVarName",
	   "CovCumulativeReport",
	   "UnderSpecifiedDataTypeMsg",
	   "DiscreteInheritContinuousMsg",
	   "ParameterDowncastMsg",
	   "ParameterOverflowMsg",
	   "ParameterPrecisionLossMsg",
	   "ParamWorkspaceSource",
	   "TLCAssertion",
	   "ConditionallyExecuteInputs",
	   "AssertionControl",
	   "DataTypeOverride",
	   "MinMaxOverflowLogging",
	   "MinMaxOverflowArchiveMode",
           "SaveDefaultBlockParams",
	   "ProdHWCharacteristics",
	   "ProdHWWordLengths",
	   "ProdHWDeviceType",
	   "TransDelayFeedthrough",
	   "LinearizeMemory",
	   "SignalLoggingName");

   return @string; 
}


sub GetFileBlocksPosVector
{
 #Creates vectors with the line positions for the FixPt blocks  
  ($mdl) =  @_;
  open(FH, "<$mdl") || die "Unable to open $mdl";
  while (<FH>) {
    if(/\s*Tag\s*\"FixPtSumSaveAsR12\"\s*$/) {
      push(@FilePosFixPtSumBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtGainSaveAsR12\"\s*$/) {
      push(@FilePosFixPtGainBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtLookup2DSaveAsR12\"\s*$/) {
      push(@FilePosFixPtLookup2DBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtLookupSaveAsR12\"\s*$/) {
      push(@FilePosFixPtLookupBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtProductSaveAsR12\"\s*$/) {
      push(@FilePosFixPtProductBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtUnitDelaySaveAsR12\"\s*$/) {
      push(@FilePosFixPtUnitDelayBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtAbsSaveAsR12\"\s*$/) {
      push(@FilePosFixPtAbsBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtSignumSaveAsR12\"\s*$/) {
      push(@FilePosFixPtSignumBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtLogicSaveAsR12\"\s*$/) {
      push(@FilePosFixPtLogicBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtSwitchSaveAsR12\"\s*$/) {
      push(@FilePosFixPtSwitchBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtMultiPortSwitchSaveAsR12\"\s*$/) {
      push(@FilePosFixPtMultiPortSwitchBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtRelaySaveAsR12\"\s*$/) {
      push(@FilePosFixPtRelayBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtConstantSaveAsR12\"\s*$/) {
      push(@FilePosFixPtConstantBlocks, $.); 
    }
    if(/\s*Tag\s*\"FixPtRelationalOperatorSaveAsR12\"\s*$/) {
      push(@FilePosFixPtRelationalOperatorBlocks, $.); 
    }
    if(/\s*SourceBlock\s+\"simulink\/Signal\\nAttributes\/Rate.*/){
      push(@FilePosRateTransitionVector, $.); 
    }
    # Model Verifications Block
    if(/\s*SourceBlock\s+\"simulink\/Model\\nVerification.*/){
      push(@FilePosModelVerification, $.); 
    }

  }
}

sub CreateSubsystem{

my($NameBlk, $NumPorts, $NumOutPorts) = @_;

 my($i);
 my($offset);
 my($offsetO);
 my($yI);
 my($hI);
 my($yG);
 my($hG);
 my($yT);
 my($hT);
 my($yO);
 my($hO);
 my($BInports); 
 my($BGround);
 my($BTerm);
 my($InL);
 my($OutL); 
 my($BOutport);

$Body1= "      Description	     \"Replaced Block\"
      BackgroundColor          \"yellow\"
      ShowPortLabels	       on
      MaskType	               \"Replaced Block\"
      MaskDescription      \"This is an R13 block which was replaced with an \"
\"empty Subsystem.\"
      MaskDisplay	      \"disp\('Replaced\\\\nBlock'\)\"
      MaskIconFrame	       on
      MaskIconOpaque	       on
      MaskIconRotate	      \"none\"
      MaskIconUnits	      \"autoscale\"
      System {
        Name	   $NameBlk
        Location		        [148, 182, 469, 270]
        Open			off
        ModelBrowserVisibility	off
        ModelBrowserWidth	        200
        ScreenColor		       \"white\"
        PaperOrientation	       \"landscape\"
        PaperPositionMode	       \"auto\"
        PaperType		       \"usletter\"
        PaperUnits		       \"inches\"
        ZoomFactor		       \"100\"
        AutoZoom		       on\n";

 for($i=1; $i<=$NumPorts; $i++){
   $yI = 23 + $offset;
   $hI = 37 + $offset;
   $yT = 20 + $offset;
   $hT = 40 + $offset;

   @BlockInports[$i] = "\t        Block {
	\t  BlockType		  Inport
	\t   Name			  \"In$i\"
	\t   Position		  [35, $yI, 65, $hI]
	\t   Port			  \"$i\"
	\t   PortWidth		  \"-1\"
	\t   SampleTime		  \"-1\"
	\t   DataType		  \"auto\"
	\t   SignalType		  \"auto\"
	\t Interpolate		  on
	\t }\n";
        
    @BlockTerm[$i]= "\t      Block {
	\t BlockType		  Terminator
	\t Name			  \"InTerminator$i\"
	\t Position		  [100, $yT, 120, $hT]
	\t}\n";
  
    @InLine[$i] = "\t       Line {
	\t  SrcBlock		  \"In$i\"
	\t SrcPort		  1
	\t DstBlock		  \"InTerminator$i\"
	\t DstPort		  1
	\t}\n";

   $offset = $offset + 60;
  }


 for($i=1; $i<=$NumOutPorts; $i++){
   $yO = 23 + $offsetO;
   $hO = 37 + $offsetO;
   $yG = 20 + $offsetO;
   $hG = 40 + $offsetO;

  @OutPort[$i] = "\t    Block {
 	\t  BlockType		  Outport
	\t  Name			  \"Out$i\"
	\t  Position		  [250, $yO, 280, $hO]
	\t  Port			  \"$i\"
	\t OutputWhenDisabled	  \"\held\"
	\t  InitialOutput		  \"[]\"
	\t}\n";

  @BlockGround[$i] ="\t     Block {
	\t  BlockType		  Ground
	\t  Name			  \"OutGround$i\"
	\t  Position		  [165, $yG, 185, $hG]
	\t }\n";

  @OutLine[$i] = "\t      Line {
	\t  SrcBlock		  \"OutGround$i\"
	\t  SrcPort		  1
	\t  DstBlock		  \"Out$i\"
	\t  DstPort		  1
	\t}\n";

  $offsetO = $offsetO + 60;
 }
 # Input blocks:
 # Inport--->Term
 for($i=1; $i<=$NumPorts; $i++){
   $BInports = $BInports . $BlockInports[$i];
   $BTerm = $BTerm . $BlockTerm[$i];
   $InL = $InL . $InLine[$i];
 }

 # Output blocks
 # Ground--->Outport
 for($i=1; $i<=$NumOutPorts; $i++){
   $BGround = $BGround . $BlockGround[$i];
   $BOutport = $BOutport . $OutPort[$i];
   $OutL = $OutL . $OutLine[$i];
 }


 $GenSubsys =  $Body1 .  $BInports . $BTerm . $BGround . $BOutport . $InL . $OutL . "       }";

 return $GenSubsys;
}





