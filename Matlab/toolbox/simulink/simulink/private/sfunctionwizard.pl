#  Name:
#     sfunctionwizard.pl-- generats an S-function for Simulink
#  Usage:
#    to be called by $MATLAB/toolbox/simulink/simulink/sfunctionwizard.m
#
# Copyright 1990-2004 The MathWorks, Inc.
# $Revision: 1.18.4.7 $
# Ricardo Monteiro 01/26/2001

($sfunName, $mdlOutputTempFile, $mdlUpdateTempFile, $headersTempFile, $legacy_c, $pathFcnCall,
 $FileParams, $mdlDerivativeTempFile,@userlibs) = @ARGV;
#####################
# Global variables  #
#####################
 @InDataType  = ();
 @InRow  = ();
 @InCol = ();
 @InComplexity = ();
 @InFrameBased =  ();
 @Inframe = ();
 @inDataTypeMacro = ();

 @OutRow  = ();
 @OutCol = ();
 @OutDataType = ();
 @OutComplexity = ();
 @OutFrameBased =  ();
 @outDataTypeMacro =();

 @ParameterName       = ();
 @ParameterDataType   = ();
 @ParameterComplexity = ();
 $EMPTY_SPACE = "                         ";
 $EMPTY_SPACE1= "                     ";
 $EMPTY_SPACE2= "                  ";

#####################
# Read Params File  #
#####################
open(INFileParams, "<$FileParams") || die "Unable to open  $FileParams";
while (<INFileParams>) {  
    my($line) = $_;
    chomp($line);


 if($line =~ /NumberOfInputPorts/){
   $NumberOfInputPorts  = substr($line, index($line,"=") + 1);
 }

 if($line =~ /NumberOfOutputPorts/){
   $NumberOfOutputPorts  = substr($line, index($line,"=") + 1);
 }

 for($i=0;$i<$NumberOfInputPorts; $i++){
   $n = $i+1;
   $p = "InPort" . $n;
   if(/$p\{/.../\}\s*$/) {
     $InPortNameStr = "inPortName" . $n;
     $InRowStr = "inRow" . $n;
     $InColStr = "inCol" . $n;
     $InDataTypeStr = "inDataType" . $n;
     $InComplexityStr = "inComplexity" . $n;
     $InFrameBasedStr = "inFrameBased" . $n;
     $InDimsStr = "inDims" . $n;
     $InIsSignedStr = "inIsSigned" . $n;
     $InWordLengthStr = "inWordLength" . $n;
     $InFractionLengthStr = "inFractionLength" . $n;
     $InFixPointScalingTypeStr = "inFixPointScalingType" . $n;
     $InBiasStr = "inBias" . $n;
     $InSlopeStr = "inSlope" . $n;

     if($line =~ /\b$InPortNameStr\b/) {
       @InPortName[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InRowStr\b/) {
       @InRow[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InColStr\b/) {
       @InCol[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InDataTypeStr\b/) {
       @InDataType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InComplexityStr\b/) {
       @InComplexity[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InFrameBasedStr\b/) {
       @InFrameBased[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InDimsStr\b/) {
       @InDims[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InIsSignedStr\b/) {
       @InIsSigned[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InWordLengthStr\b/) {
       @InWordLength[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InFractionLengthStr\b/) {
       @InFractionLength[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$InFixPointScalingTypeStr\b/) {
       @InFixPointScalingType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$InBiasStr\b/) {
       @InBias[$i]  = substr($line, index($line,"=") + 1);
     }
     if($line  =~ /\b$InSlopeStr\b/) {
       @InSlope[$i]  = substr($line, index($line,"=") + 1);
     }


   }
 } #end for

 for($i=0;$i<$NumberOfOutputPorts; $i++){
   $n = $i+1;
   $p = "OutPort" . $n;
   if(/$p\{/.../\}\s*$/) {
     $OutPortNameStr = "outPortName" . $n;
     $OutRowStr = "outRow" . $n;
     $OutColStr = "outCol" . $n;
     $OutDataTypeStr = "outDataType" . $n;
     $OutComplexityStr = "outComplexity" . $n;
     $OutFrameBasedStr = "outFrameBased" . $n;
     $OutDimsStr = "outDims" . $n;
     $OutIsSignedStr = "outIsSigned" . $n;
     $OutWordLengthStr = "outWordLength" . $n;
     $OutFractionLengthStr = "outFractionLength" . $n;
     $OutFixPointScalingTypeStr = "outFixPointScalingType" . $n;
     $BiasStr = "outBias" . $n;
     $SlopeStr = "outSlope" . $n;

     if($line =~ /\b$OutPortNameStr\b/) {
       @OutPortName[$i]  = substr($line, index($line,"=") + 1);
     }
    
     if($line =~ /\b$OutRowStr\b/) {
       @OutRow[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutColStr\b/) {
       @OutCol[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutDataTypeStr\b/) {
       @OutDataType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutComplexityStr\b/) {
       @OutComplexity[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutFrameBasedStr\b/) {
       @OutFrameBased[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutDimsStr\b/) {
       @OutDims[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutIsSignedStr\b/) {
       @OutIsSigned[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutWordLengthStr\b/) {
       @OutWordLength[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$OutFractionLengthStr\b/) {
       @OutFractionLength[$i]  = substr($line, index($line,"=") + 1);
     }
     
     if($line  =~ /\b$OutFixPointScalingTypeStr\b/) {
       @OutFixPointScalingType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$BiasStr\b/) {
       @OutBias[$i]  = substr($line, index($line,"=") + 1);
     }
     if($line  =~ /\b$SlopeStr\b/) {
       @OutSlope[$i]  = substr($line, index($line,"=") + 1);
     }

   }
 } #end for


    if($line =~ /NumberOfInputs/){
      $InRow[0]  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /NumberOfOutputs/){
      $OutRow[0]  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /directFeed/){
      $directFeed  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /NumOfDStates/){
      $NumDiscStates  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /DStatesIC/){
      $DStatesIC = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /NumOfCStates/){
      $NumContStates = substr($line, index($line,"=") + 1);
    }
    if($line =~ /CStatesIC/){
      $CStatesIC = substr($line, index($line,"=") + 1);
    }
    if($line =~ /SampleTime/){
      $sampleTime = substr($line, index($line,"=") + 1);
    }
    if($line =~ /NumberOfParameters/){
      $NumParams = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /CreateWrapperTLC/){
      $CreateWrapperTLC = substr($line, index($line,"=") + 1);
    }
    if($line =~ /LibList/){
      $LibrarySourceFiles  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /PanelIndex/){
      $PanelIndex  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /TemplateType/){
      $TemplateType  = substr($line, index($line,"=") + 1);
    } else { 
      $TemplateType = '1';
    }
    if($line =~ /InputDims_0_col/){
      $InputDim_0_Col  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /OutputDims_0_col/){
      $OutputDim_0_Col  = substr($line, index($line,"=") + 1);
    }

    for($i=0;$i<$NumParams; $i++){
      $n = $i+1;
      $p = "Parameter" . $n;
      if(/$p\{/.../\}\s*$/) {
	$ParameterNameStr = "parameterName" . $n;
	$ParameterDataTypeStr = "parameterDataType" . $n;
	$ParameterComplexityStr = "parameterComplexity" . $n;
	
	if($line =~ /\b$ParameterNameStr\b/) {
	  @ParameterName[$i]  = substr($line, index($line,"=") + 1);
	}
	
	if($line =~ /\b$ParameterDataTypeStr\b/) {
	  @ParameterDataType[$i]  = substr($line, index($line,"=") + 1);
	}
	
	if($line =~ /\b$ParameterComplexityStr\b/) {
	  @ParameterComplexity[$i]  = substr($line, index($line,"=") + 1);
	}
	
      }
    } #end for

    if($line =~ /GenerateStartFunction/){
      $GenerateStartFunction  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /GenerateTerminateFunction/){
      $GenerateTerminateFunction  = substr($line, index($line,"=") + 1);
    }
  }

close(INFileParams);
for($i=0;$i<$NumberOfInputPorts; $i++) {
 # Create the data type macro
 # for exmaple SS_BOOLEAN
 $inDataTypeMacro[$i] = getDataTypeMacros($InDataType[$i]);

 if($InFrameBased[$i] =~ "FRAME_YES" || $InFrameBased[$i] =~ "FRAME_INHERITED")
 {
   $Inframe[$i] = '1';
 } else {
   $Inframe[$i] = '0';
 }
}

for($i=0;$i<$NumberOfOutputPorts; $i++) {
 $outDataTypeMacro[$i] = getDataTypeMacros($OutDataType[$i]);
}

for($i=0;$i<$NumParams; $i++) {
 $ParameterDataTypeMacro[$i] = getDataTypeMacros($ParameterDataType[$i]);
}
# Remove .c from the S-function name #
@n = split(/\./,$sfunName);
$sFName = @n[0];

# Set the path to the sfunwiz_template.c according to the platform
if($pathFcnCall =~ /\//) {
    $sfun_template = "$pathFcnCall/sfunwiz_template.c.tmpl";
    $sfun_template_wrapper = "$pathFcnCall/sfunwiz_template_wrapper.c.tmpl";
    $sfun_template_wrapperTLC = "$pathFcnCall/sfunwiz_template.tlc";
}
else {
    $sfun_template = "$pathFcnCall\\sfunwiz_template.c.tmpl";
    $sfun_template_wrapper = "$pathFcnCall\\sfunwiz_template_wrapper.c.tmpl";
    $sfun_template_wrapperTLC = "$pathFcnCall\\sfunwiz_template.tlc";
}

$sfunNameWrapper = $sFName . "_wrapper.c";
$sfunNameWrapperTLC = $sFName . ".tlc";

$SfunDir =`pwd`; 
open(OUT,">$sfunName") || die "Unable to create $sfunName. Please check the directory permission:\n $SfunDir \n";
open(OUTWrapper,">$sfunNameWrapper") || die "Unable to create $sfunNameWrapper Please check the directory permission\n";
open(IN, "<$sfun_template") || die "Unable to open $sfun_template ";
open(INWrapper, "<$sfun_template_wrapper") || die "Unable to open $sfun_template_wrapper ";
open(HTEMP,"<$mdlOutputTempFile") || die "Unable to open $mdlOutputTempFile";


$strDStates = "NO_USER_DEFINED_DISCRETE_STATES";
if( $mdlUpdateTempFile =~ /$strDStates/){
      $flagdStates = 0;
    }
else {
  open(dStatesHandle,"<$mdlUpdateTempFile") || die "Unable to open $mdlUpdateTempFile";
  @discStatesArray  = <dStatesHandle>;
  $flagdStates = 1;
}

$strCStates = "NO_USER_DEFINED_CONTINUOS_STATES";
if( $mdlDerivativeTempFile =~ /$strCStates/){
      $flagCStates = 0;
    }
else {
  open(CStatesHandle,"<$mdlDerivativeTempFile") || die "Unable to open $mdlDerivativeTempFile";
  @contStatesArray  = <CStatesHandle>;
  $flagCStates = 1;
}



$strH = "NO_USER_DEFINED_HEADER_CODE";
if($headersTempFile =~ /$strH/){
      $flagH = 0;
    }
else {
  open(HeaderF,"<$headersTempFile") || die "Unable to open $headersTempFile";
  @headerArray  = <HeaderF>;
  $flagH = 1;
}

$strC = "NO_USER_DEFINED_C_CODE";
if($legacy_c =~ $strC) {
  $flagL = 0;
}
else {
  open(HC,"<$legacy_c") || die "Unable to open $legacy_c";
  @externDeclarationsArray  = <HC>;
  $flagL = 1;
}


# declare 'width' in case output port width is -1
$strDynSize =  'DYNAMICALLY_SIZED';
$flagDynSize = 0;
if(($OutRow[0] =~ $strDynSize) || ($InRow[0] =~ $strDynSize)) {
  $flagDynSize = 1;
} else { 
  # Use to #define the u_width and y_width 
  $flagDynSize = 2;

} 

$strDynSize =  'DYNAMICALLY_SIZED';
if($InRow[0] == -1 && $NumberOfInputPorts == 1) {
  $InRow[0] = $strDynSize;
}
if($OutRow[0] == -1 && $NumberOfOutputPorts == 1) {
  $OutRow[0] = $strDynSize;
}

# Time Stamp
$timeString = localtime;

# Read mdlOutputTempFile into an array #
@mdlOutputArray = <HTEMP>;

$UpdatefcnStr = "Update";
$stateDStr = "xD";
$fcnProtoTypeUpdate =  genStatesWrapper($NumParams,$NumDiscStates,$UpdatefcnStr,
					$stateDStr, $sFName,$InDataType[0],$OutDataType[0], 0);
$fcnCallUpdate = genFunctionCall($NumParams,$NumDiscStates,$UpdatefcnStr,$stateDStr, $sFName);
$wrapperExternDeclarationUpdate =  "extern $fcnProtoTypeUpdate;\n";

$fcnProtoTypeUpdateTLC =  genStatesWrapper($NumParams,$NumDiscStates,$UpdatefcnStr,
					$stateDStr, $sFName,$InDataType[0],$OutDataType[0], 1);
$wrapperExternDeclarationUpdateTLC =  "extern $fcnProtoTypeUpdateTLC;\n";

$DerivativesfcnStr = "Derivatives";
$stateCStr = "xC";
$fcnProtoTypeDerivatives =  genStatesWrapper($NumParams,$NumContStates,$DerivativesfcnStr,
					     $stateCStr, $sFName,$InDataType[0],$OutDataType[0], 0);
$fcnCallDerivatives = genFunctionCall($NumParams,$NumContStates,$DerivativesfcnStr,$stateCStr ,$sFName);
$wrapperExternDeclarationDerivatives =  "extern $fcnProtoTypeDerivatives;\n";

$fcnProtoTypeDerivativesTLC =  genStatesWrapper($NumParams,$NumContStates,$DerivativesfcnStr,
					     $stateCStr, $sFName,$InDataType[0],$OutDataType[0], 1);
$wrapperExternDeclarationDerivativesTLC =  "extern $fcnProtoTypeDerivativesTLC;\n";

$OutputfcnStr = "Outputs";
$fcnProtoTypeOutput =  genOutputWrapper($NumParams, $NumDiscStates, $NumContStates, 
					$OutputfcnStr, $sFName, $flagDynSize,$InDataType[0],$OutDataType[0], 0);
$fcnCallOutput =  genFunctionCallOutput($NumParams, $NumDiscStates,$NumContStates, $OutputfcnStr, $sFName, $flagDynSize);
$wrapperExternDeclarationOutput =  "extern $fcnProtoTypeOutput;\n";

$fcnProtoTypeOutputTLC =  genOutputWrapper($NumParams, $NumDiscStates, $NumContStates, 
					$OutputfcnStr, $sFName, $flagDynSize,$InDataType[0],$OutDataType[0], 1);
$wrapperExternDeclarationOutputTLC =  "extern $fcnProtoTypeOutputTLC;\n";

#Trim the list of source/lib files to be printend in the generated S-function
@vectorLib = split(',', $LibrarySourceFiles);
foreach $Lib (@vectorLib){
  $Lib =~ s/\'//;
  $Lib =~ s/\'//;
  $LibLists = "$LibLists $Lib";
}
$LibLists =~ s/\s//;

##########################
# Create the S-function  #
##########################
while (<IN>) {  
  my($line) = $_;
  
  # comments
  if($. == 2) {
    print OUT " * File: $sfunName\n";
  }

  if($. == 3) {
    $strIntro = genIntro();
    print OUT $strIntro; 
  }

  if($. == 4) {
    print OUT " * Created: $timeString\n";
  }
  #Don't print Copyright
  if($. == 6 ) { next; }
  if($. == 7 ) { next; }
  
  ################### 
  # S-function name #
  ###################
  if($. == 11 ){
    print OUT "#define S_FUNCTION_NAME $sFName";
  }

  if (/--Builder Defines--/){   
print  OUT "/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
/* %%%-SFUNWIZ_defines_Changes_BEGIN --- EDIT HERE TO _END */\n";
print OUT "#define NUM_INPUTS          $NumberOfInputPorts\n";               

for($i=0;$i<$NumberOfInputPorts; $i++){
  print OUT "/* Input Port  $i */\n";
  print OUT "#define IN_PORT_$i\_NAME      $InPortName[$i]\n";
  print OUT "#define INPUT_$i\_WIDTH       $InRow[$i]\n";
  print OUT "#define INPUT_DIMS_$i\_COL    $InCol[$i]\n";
  print OUT "#define INPUT_$i\_DTYPE       $InDataType[$i]\n";
  print OUT "#define INPUT_$i\_COMPLEX     $InComplexity[$i]\n";
  print OUT "#define IN_$i\_FRAME_BASED    $InFrameBased[$i]\n";
  print OUT "#define IN_$i\_DIMS           $InDims[$i]\n";
  print OUT "#define INPUT_$i\_FEEDTHROUGH $directFeed\n";
  if($InDataType[$i] =="fixpt"){
    print OUT "#define IN_$i\_ISSIGNED        $InIsSigned[$i]\n";
    print OUT "#define IN_$i\_WORDLENGTH      $InWordLength[$i]\n";
    print OUT "#define IN_$i\_FIXPOINTSCALING $InFixPointScalingType[$i]\n";
    print OUT "#define IN_$i\_FRACTIONLENGTH  $InFractionLength[$i]\n";
    print OUT "#define IN_$i\_BIAS            $InBias[$i]\n";
    print OUT "#define IN_$i\_SLOPE           $InSlope[$i]\n";
  }
}

print OUT "\n#define NUM_OUTPUTS          $NumberOfOutputPorts\n";
for($i=0;$i<$NumberOfOutputPorts; $i++){
  print OUT "/* Output Port  $i */\n";
  print OUT "#define OUT_PORT_$i\_NAME      $OutPortName[$i]\n";
  print OUT "#define OUTPUT_$i\_WIDTH       $OutRow[$i]\n";
  print OUT "#define OUTPUT_DIMS_$i\_COL    $OutCol[$i]\n";
  print OUT "#define OUTPUT_$i\_DTYPE       $OutDataType[$i]\n";
  print OUT "#define OUTPUT_$i\_COMPLEX     $OutComplexity[$i]\n";
  print OUT "#define OUT_$i\_FRAME_BASED    $OutFrameBased[$i]\n";
  print OUT "#define OUT_$i\_DIMS           $OutDims[$i]\n";
  if($OutDataType[$i] =~ /\bfixpt\b/ ){
    print OUT "#define OUT_$i\_ISSIGNED        $OutIsSigned[$i]\n";
    print OUT "#define OUT_$i\_WORDLENGTH      $OutWordLength[$i]\n";
    print OUT "#define OUT_$i\_FIXPOINTSCALING $OutFixPointScalingType[$i]\n";
    print OUT "#define OUT_$i\_FRACTIONLENGTH  $OutFractionLength[$i]\n";
    print OUT "#define OUT_$i\_BIAS            $OutBias[$i]\n";
    print OUT "#define OUT_$i\_SLOPE           $OutSlope[$i]\n";
  }
}

print OUT "\n#define NPARAMS              $NumParams\n";
for($i=0;$i<$NumParams; $i++){
  $n = $i+1;
  print OUT "/* Parameter  $n */\n";
  print OUT "#define PARAMETER_$i\_NAME      $ParameterName[$i]\n";
  print OUT "#define PARAMETER_$i\_DTYPE     $ParameterDataType[$i]\n";
  print OUT "#define PARAMETER_$i\_COMPLEX   $ParameterComplexity[$i]\n";
}

#print OUT "#define NPARAMS              $NumParams
print OUT "\n#define SAMPLE_TIME_0        $sampleTime
#define NUM_DISC_STATES      $NumDiscStates
#define DISC_STATES_IC       [$DStatesIC]
#define NUM_CONT_STATES      $NumContStates
#define CONT_STATES_IC       [$CStatesIC]

#define SFUNWIZ_GENERATE_TLC $CreateWrapperTLC
#define SOURCEFILES \"$LibLists\"
#define PANELINDEX           $PanelIndex
#define SFUNWIZ_REVISION     3.0\n";
     print OUT  "/* %%%-SFUNWIZ_defines_Changes_END --- EDIT HERE TO _BEGIN */
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/\n";

    next;
  }  

  $IsFixedBeingPropagated = 0;
  for($i=0;$i<$NumberOfInputPorts; $i++){
    if($InDataType[$i] =~ /\bfixpt\b/) {
      $IsFixedBeingPropagated = 1;
      last;
    }
  }

  if($IsFixedBeingPropagated == 0) {
    for($i=0;$i<$NumberOfOutputPorts; $i++){
      if($OutDataType[$i] =~ /\bfixpt\b/) {
	$IsFixedBeingPropagated = 1;
	last;
      }
    }
  }
  if(/--IncludeFixedPointDotH--/) {
    if($IsFixedBeingPropagated == 1) {
      print OUT "#include \"fixedpoint.h\"\n"; 
    }
    next;
  } 
 ###########
 # Defines #
 ###########
 %defines_repeat_hash = ();
 if (/--Parameters Defines--/){  
   for($i=0; $i < $NumParams ; $i++){
       print OUT "#define PARAM_DEF$i(S) ssGetSFcnParam(S, $i)\n";
     }

# (xxx) make this into a table
  for($i=0; $i < $NumParams ; $i++){
    if($ParameterComplexity[$i]  =~ /COMPLEX_NO/) {
      if($ParameterDataType[$i] =~ /\breal_T\b/) {
        next if ($defines_repeat_hash{real_T}++ > 0);
	print OUT "\n#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))\n";
      }

      if($ParameterDataType[$i] =~ /\breal32_T\b/) {
        next if ($defines_repeat_hash{real32_T}++ > 0);
	print OUT "\n#define IS_PARAM_SINGLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsSingle(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bint8_T\b/) {
        next if ($defines_repeat_hash{int8_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT8(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsInt8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bint16_T\b/) {
        next if ($defines_repeat_hash{int16_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT16(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsInt16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bint32_T\b/) {
        next if ($defines_repeat_hash{int32_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT32(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsInt32(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\buint8_T\b/) {
        next if ($defines_repeat_hash{uint8_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT8(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsUint8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\buint16_T\b/) {
        next if ($defines_repeat_hash{uint16_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT16(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsUint16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\buint32_T\b/) {
        next if ($defines_repeat_hash{uint32_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT32(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsUint32(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bboolean_T\b/) {    
        next if ($defines_repeat_hash{boolean_T}++ > 0);
	print OUT "\n#define IS_PARAM_BOOLEAN(pVal) (mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal))\n";
      }
    }

    if($ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
      if($ParameterDataType[$i] =~ /\bcreal_T\b/) {
        next if ($defines_repeat_hash{creal_T}++ > 0);
	print OUT "\n#define IS_PARAM_DOUBLE_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsDouble(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcreal32_T\b/) {
        next if ($defines_repeat_hash{creal32_T}++ > 0);
	print OUT "\n#define IS_PARAM_SINGLE_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsSingle(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcint8_T\b/) {
        next if ($defines_repeat_hash{cint8_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT8_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsInt8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcint16_T\b/) {
        next if ($defines_repeat_hash{cint16_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT16_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsInt16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcint32_T\b/) {
        next if ($defines_repeat_hash{cint32_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT32_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsInt32(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcuint8_T\b/) {
        next if ($defines_repeat_hash{cuint8_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT8_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsUint8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcuint16_T\b/) {
        next if ($defines_repeat_hash{cuint16_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT16_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsUint16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcuint32_T\b/) {
        next if ($defines_repeat_hash{cuint32_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT32_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsUint32(pVal))\n";
      }
    }
  }
   next;
 }

 ######################
 # Extern declaration #
 ######################
  if(/--ExternDeclarationOutputs--/){
   print OUT $wrapperExternDeclarationOutput;
    next;
  }

  if(/--ExternDeclarationUpdates--/) {
    if($NumDiscStates){
     print OUT $wrapperExternDeclarationUpdate;
    }
    next;
  }
  if(/--ExternDeclarationDerivatives--/){
    if($NumContStates){
     print OUT $wrapperExternDeclarationDerivatives;
    }
    next;
  }
  #####################
  #mdlCheckParameters # 
  #####################
  if(/--MDL_CHECK_PARAMETERS--/){
    if ($NumParams){
      $method = get_mdlCheckParameters_method(); 
      print  OUT $method;
    }
    next;
  }
  ######################
  # mdlInitializeSizes #
  ######################
  if(/--ParametersDeclaration--/) {
    if($NumberOfInputPorts > 0) {
       print OUT  "    DECL_AND_INIT_DIMSINFO(inputDimsInfo);\n";
     }
       print OUT  "    DECL_AND_INIT_DIMSINFO(outputDimsInfo);\n";
     $parameterDeclaration = get_parameters_declaration($NumParams);
     print OUT $parameterDeclaration;
     next;
 } 

  if(/--ssSetNumContStates--/){
    print OUT  "    ssSetNumContStates(S, NUM_CONT_STATES);\n";
    next;
  } 
  if(/--ssSetNumDiscStates--/){
    print OUT  "    ssSetNumDiscStates(S, NUM_DISC_STATES);\n";
    next;
  } 

  if(/--ssSetNumInputPortsInfo--/) {
    print OUT "    if (!ssSetNumInputPorts(S, NUM_INPUTS)) return;\n";
    next;
  }
if(/--ssSetInputPortInformation--/) {
 if ($NumberOfInputPorts == 1 && $InDims[0] == "1-D") {
  if( ($InRow[0] == $OutRow[0] || $OutRow[0] == 1)  && 
	($InRow[0] > 1 || ($InRow[0] =~ $strDynSize)) ) {
      print OUT "    inputDimsInfo.width = INPUT_0_WIDTH;";
      print OUT "\n    ssSetInputPortDimensionInfo(S, 0, &inputDimsInfo);";
      if($Inframe[0] == 1) {
	print OUT "\n    ssSetInputPortMatrixDimensions(  S ,0, INPUT_0_WIDTH, INPUT_DIMS_0_COL);";
      }
      print OUT "\n    ssSetInputPortFrameData(S, 0, IN_0_FRAME_BASED);";
      if($InDataType[0] =~ /\bfixpt\b/) {
	if($InFixPointScalingType[0] == 1) {
	  print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_SLOPE,
            IN_0_BIAS,
            1 );";
	} else {
	  print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_FRACTIONLENGTH,
            1 );";
	}
	print OUT "\n    ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]" . "_0);\n }";
       } else {
         print OUT "\n    ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]);";
       }
      print OUT "\n    ssSetInputPortComplexSignal(S, 0, INPUT_0_COMPLEX);";  
    } else {
	if($Inframe[0] == 1) {
	  print OUT "    inputDimsInfo.width = INPUT_0_WIDTH;";
	  print OUT "\n    ssSetInputPortDimensionInfo(S, 0, &inputDimsInfo);";
	  print OUT "\n    ssSetInputPortMatrixDimensions(  S ,0, INPUT_0_WIDTH, INPUT_DIMS_0_COL);";
	  print OUT "\n    ssSetInputPortFrameData(S, 0, IN_0_FRAME_BASED);\n";
	}
	if($Inframe[0] == 0) {
	  print OUT "    ssSetInputPortWidth(S, 0, INPUT_0_WIDTH);";
	}

	if($InDataType[0] =~ /\bfixpt\b/) {
	  if($InFixPointScalingType[0] == 1) {
	    print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_SLOPE,
            IN_0_BIAS,
            1 );";
	  } else {
	    print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_FRACTIONLENGTH,
            1 );";
	  }
	  print OUT "\n     ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]" . "_0);\n    }";
	} else {
	  print OUT "\n    ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]);";
       }
	print OUT "\n    ssSetInputPortComplexSignal(S, 0, INPUT_0_COMPLEX);";  
      }
  print OUT "\n    ssSetInputPortDirectFeedThrough(S, 0, INPUT_0_FEEDTHROUGH);";
  print OUT "\n    ssSetInputPortRequiredContiguous(S, 0, 1); /*direct input signal access*/\n";
} else {
  for($i=0;$i<$NumberOfInputPorts; $i++) {
     print OUT "    /*Input Port $i */\n";
    if ($InRow[$i] > 1 || ($InRow[$i] =~ $strDynSize)) {
      if ($InCol[$i] > 1 || $Inframe[$i] == 1) {
	print OUT "    inputDimsInfo.width = INPUT_$i\_WIDTH;";
	print OUT "\n    ssSetInputPortDimensionInfo(S, $i, &inputDimsInfo);";
	print OUT "\n    ssSetInputPortMatrixDimensions(  S ,$i, INPUT_$i\_WIDTH, INPUT_DIMS_$i\_COL);";
	print OUT "\n    ssSetInputPortFrameData(S, $i, IN_$i\_FRAME_BASED);";
      } else  {
	print OUT "    ssSetInputPortWidth(S,  $i, INPUT_$i\_WIDTH);";
      }

      if($InDataType[$i] =~ /\bfixpt\b/) {
	if($InFixPointScalingType[$i] == 1) {
	  print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_SLOPE,
            IN_$i\_BIAS,
            1 );";
	 } else {
	    print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_FRACTIONLENGTH,
            1 );";
	  }
	print OUT "\n    ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]" . "\_$i);\n }";
       } else {
	 print OUT "\n    ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]);";
       }
      print OUT "\n    ssSetInputPortComplexSignal(S, $i, INPUT_$i\_COMPLEX);";  
    } else {
	if($InCol[$i] > 1 || $Inframe[$i] == 1) {
	  print OUT "    inputDimsInfo.width = INPUT_$i\_WIDTH;";
	  print OUT "\n    ssSetInputPortDimensionInfo(S,  $i, &inputDimsInfo);";
	  print OUT "\n    ssSetInputPortMatrixDimensions(  S , $i, INPUT_$i\_WIDTH, INPUT_DIMS_$i\_COL);";
	  print OUT "\n    ssSetInputPortFrameData(S,  $i, IN_$i\_FRAME_BASED);\n";
	} else {
	  print OUT "    ssSetInputPortWidth(S,  $i, INPUT_$i\_WIDTH); /* */";
	}
        if($InDataType[$i] =~ /\bfixpt\b/) {
	  if($InFixPointScalingType[$i] == 1) {
	    print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_SLOPE,
            IN_$i\_BIAS,
            1 );";
	 } else {
	    print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_FRACTIONLENGTH,
            1 );";
	  }
	  print OUT "\n      ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]" . "\_$i);\n    }";
	} else {
	  print OUT "\n    ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]);";
	}
	print OUT "\n    ssSetInputPortComplexSignal(S,  $i, INPUT_$i\_COMPLEX);";  
      }
     print OUT "\n    ssSetInputPortDirectFeedThrough(S, $i, INPUT_$i\_FEEDTHROUGH);";
     print OUT "\n    ssSetInputPortRequiredContiguous(S, $i, 1); /*direct input signal access*/\n";
     print OUT "\n";
  } #end of for loop
 }
  next;
}
  if(/--ssSetInputPortDirectFeedThroughInfo--/) {
    next;
  } 

  if(/--ssSetNumOutputPortsInfo--/) {
    print OUT "    if (!ssSetNumOutputPorts(S, NUM_OUTPUTS)) return;\n";
    next;
  }
  if(/--ssSetOutputPortInformation--/) {
      if ($NumberOfOutputPorts == 1 &&  $OutDims[0] == "1-D") {
          if(($InRow[0] == $OutRow[0] || $OutRow[0] == 1) && ($InRow[0] > 1 || ($InRow[0] =~ $strDynSize)))  {
              print OUT "    outputDimsInfo.width = OUTPUT_0_WIDTH;";
              print OUT "\n    ssSetOutputPortDimensionInfo(S, 0, &outputDimsInfo);";
              if($Inframe[0] == 1) {
                  print OUT "\n    ssSetOutputPortMatrixDimensions( S ,0, OUTPUT_0_WIDTH, OUTPUT_DIMS_0_COL);";
              }
              print OUT "\n    ssSetOutputPortFrameData(S, 0, OUT_0_FRAME_BASED);";
              if($OutDataType[0] =~ /\bfixpt\b/) {
                  if($OutFixPointScalingType[0] == 1) {
                      print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_SLOPE,
            OUT_0_BIAS,
            1 );";
                  } else {
                      print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_FRACTIONLENGTH,
            1 );";
                  }
                  print OUT "\n    ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]" . "_0);\n }";
              } else {
                  print OUT "\n    ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]);";
              }
              print OUT "\n    ssSetOutputPortComplexSignal(S, 0, OUTPUT_0_COMPLEX);";  
          } else {
              # generate calls for Detailed template
              if($Inframe[0] == 1) {
                  print OUT "    outputDimsInfo.width = OUTPUT_0_WIDTH;";
                  print OUT "\n    ssSetOutputPortDimensionInfo(S, 0, &outputDimsInfo);";
                  print OUT "\n    ssSetOutputPortMatrixDimensions( S ,0, OUTPUT_0_WIDTH, OUTPUT_DIMS_0_COL);";
                  print OUT "\n    ssSetOutputPortFrameData(S, 0, OUT_0_FRAME_BASED);\n";
              }
              if($Inframe[0] == 0) {
                  print OUT "    ssSetOutputPortWidth(S, 0, OUTPUT_0_WIDTH);";
              }
              if($OutDataType[0] =~ /\bfixpt\b/) {
                  if($OutFixPointScalingType[0] == 1) {
                      print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_SLOPE,
            OUT_0_BIAS,
            1 );";
                  } else {
                      print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_FRACTIONLENGTH,
            1 );";
                  }
                  print OUT "\n      ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]" . "_0);\n    }";
              } else {
                  print OUT "\n    ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]);";
              }
              print OUT "\n    ssSetOutputPortComplexSignal(S, 0, OUTPUT_0_COMPLEX);";  
          }
      } else {
          for($i=0;$i<$NumberOfOutputPorts; $i++) {
              print OUT "    /* Output Port $i */\n";
              if ($OutCol[$i] > 1 || ($OutFrameBased[$i] eq 'FRAME_YES') || ($OutDims[$i] eq '2-D')) {
                  print OUT "    outputDimsInfo.width = OUTPUT_$i\_WIDTH;";
                  print OUT "\n    ssSetOutputPortDimensionInfo(S, $i, &outputDimsInfo);";
                  print OUT "\n    ssSetOutputPortMatrixDimensions( S ,$i, OUTPUT_$i\_WIDTH, OUTPUT_DIMS_$i\_COL);";
                  print OUT "\n    ssSetOutputPortFrameData(S, $i, OUT_$i\_FRAME_BASED);";
              } else {
                  print OUT "    ssSetOutputPortWidth(S, $i, OUTPUT_$i\_WIDTH);";
              }
              if($OutDataType[$i] =~ /\bfixpt\b/) {
                  if($OutFixPointScalingType[$i] == 1) {
                      print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpSlopeBias(
            S,
            OUT_$i\_ISSIGNED,
            OUT_$i\_WORDLENGTH,
            OUT_$i\_SLOPE,
            OUT_$i\_BIAS,
            1 );";
                  } else {
                      print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpBinaryPoint(
            S,
            OUT_$i\_ISSIGNED,
            OUT_$i\_WORDLENGTH,
            OUT_$i\_FRACTIONLENGTH,
            1 );";
                  }
                  print OUT "\n      ssSetOutputPortDataType(S, $i, $outDataTypeMacro[$i]" . "\_$i);\n    }";
              } else {
                  print OUT "\n    ssSetOutputPortDataType(S, $i, $outDataTypeMacro[$i]);";
              }
              print OUT "\n    ssSetOutputPortComplexSignal(S, $i, OUTPUT_$i\_COMPLEX);\n";  
              
          } #end for loop
      }
      next;
  } #end if(/--ssSetOutputPortInformation--/)
  
  
  if(/--MDL_SET_PORTS_DIMENSION_INFO--/){
    if(($InRow[0] =~ $strDynSize && $OutRow[0] == 1) || 
       ($InRow[0] > 1  && $OutRow[0] == 1) ||
       ($Inframe[0] == 1)) {
      $DimsInfoMOne_One = getBodyDimsInfoWidthMdlPortWidth($InRow[0],
							    $OutRow[0],
							    $strDynSize,
							    $Inframe[0]);
      print  OUT $DimsInfoMOne_One;
     }

    $mdlSetInputPortFrameData = "# define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct  *S, 
                                     int_T      port,
                                     Frame_T    frameData)
{
    ssSetInputPortFrameData(S, port, frameData);
}\n";
  if($NumberOfInputPorts > 0) { 
    print  OUT $mdlSetInputPortFrameData;
  }
    $DimsInfoMinus_By_N = getBodyMdlPortWidthMinusByN();
   if($InRow[0] =~ $strDynSize && $OutRow[0] > 1 &&   $Inframe[0] == '0') {
      print  OUT $DimsInfoMinus_By_N;
    }
    next;
  }
  ###################################################
  # mdlInitializeSampleTime ports Data type methods #
  ###################################################
  if(/--ssSetSampleTimeInfo--/){
   $IsSampleTimeNotUsedAsParamter = 1;
   if ($NumParams){
     for($i=0;$i<$NumParams; $i++){
       if($ParameterName[$i] =~  /\b$sampleTime\b/){
        print OUT "    ssSetSampleTime(S, 0, *mxGetPr(ssGetSFcnParam(S, $i)));\n";
        $IsSampleTimeNotUsedAsParamter = 0;
        last;
       }
     }
     if($IsSampleTimeNotUsedAsParamter) {
        print OUT "    ssSetSampleTime(S, 0, SAMPLE_TIME_0);\n";
     }
   } else {
     print OUT "    ssSetSampleTime(S, 0, SAMPLE_TIME_0);\n";
   }
    next;
  } 

  if(/--MDL_INITIALIZE_CONDITIONS--/){
    if ($NumDiscStates || $NumContStates ){
      $methodInit=get_mdlInitializeConditions_method($NumDiscStates ,$DStatesIC ,$NumContStates, $CStatesIC);
      print  OUT $methodInit;
    }
    next;
  }
  if(/--MDL_START_FUNCTION--/){
     if($GenerateStartFunction > 0) {
        $startFcn = genStartFcnMethods();
        print OUT $startFcn;
     }
     next;
   }

  if(/--MDL_SET_PORTS_DATA_TYPE--/) {
    $portMethods = genPortDataTypeMethods();
    print  OUT  $portMethods;
    next;
  }
  ##############
  # mdlOutputs #
  ##############
  
  if(/--InputDataTypeDeclaration--/) {
   for($i=0;$i<$NumberOfInputPorts; $i++){
     if($InDataType[$i] =~ /\bfixpt\b/) {
       print OUT "    const DTypeId  *$InPortName[$i]  = (const DTypeId*) ssGetInputPortSignal(S,$i);\n";
     } else {
       print OUT "    const $InDataType[$i]   *$InPortName[$i]  = (const $InDataType[$i]*) ssGetInputPortSignal(S,$i);\n";
     }
   }
    next;
  }
  if(/--OutputDataTypeDeclaration--/){
    for($i=0;$i<$NumberOfOutputPorts; $i++){
      if($OutDataType[$i] =~ /\bfixpt\b/) {
        print OUT "    DTypeId        *$OutPortName[$i]  = (DTypeId *)ssGetOutputPortRealSignal(S,$i);\n";
      } else {
        print OUT "    $OutDataType[$i]        *$OutPortName[$i]  = ($OutDataType[$i] *)ssGetOutputPortRealSignal(S,$i);\n";
      }
    }
    next; 
  }

  if(/--mdlOutputsNumDiscStates--/) {
    if($NumDiscStates){
      print OUT "    const real_T   *xD = ssGetDiscStates(S);\n";
    }
    next;
  }
  if(/--mdlOutputsNumContStates--/) {
    if($NumContStates){
      print OUT "    const real_T   *xC = ssGetContStates(S);\n";
    }
    next;
  }

  if(/--mdlOutputsNumParams--/){
    for($i=0; $i < $NumParams ; $i++){
        print OUT "    const int_T   p_width$i  = mxGetNumberOfElements(PARAM_DEF$i(S));\n";
    }

    for($i=0; $i < $NumParams ; $i++) {
      if($ParameterComplexity[$i]  =~ /COMPLEX_NO/) {
      print OUT "    const $ParameterDataType[$i]  *$ParameterName[$i]  = mxGetData(PARAM_DEF$i(S));\n";
      }
    }
    @ArrayOfComplexParamsDataType = ();
    @ArrayCplxIndex = (); 
    local $k = 0;
    for($i=0; $i < $NumParams ; $i++) {
       if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
         # creal_T   kCplx;
         # creal_T *k = &kCplx;
         # kCplx.re  = (*(real_T *)mxGetData(PARAM_DEF0(S)));   
         # kCplx.im   = (*(real_T *)mxGetImagData(PARAM_DEF0(S)));   
         print OUT "    $ParameterDataType[$i]       $ParameterName[$i]" . "Cplx;\n";
         print OUT "    $ParameterDataType[$i]       *$ParameterName[$i] = &$ParameterName[$i]" ."Cplx;\n";
         $ArrayOfComplexParamsDataType[$k] = $ParameterDataType[$i];
         $ArrayCplxIndex[$k] = $i;
         $k++;
       }
     }
      local $iCplx = 0;
      foreach $ArrCplxParams (@ArrayOfComplexParamsDataType){
          $ArrCplxParams =~ s/^c//;
          print OUT "    $ParameterName[$ArrayCplxIndex[$iCplx]]" . "Cplx" . ".re      = (*($ArrCplxParams *)mxGetData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)));\n";
          print OUT "    $ParameterName[$ArrayCplxIndex[$iCplx]]" . "Cplx" . ".im      = (*($ArrCplxParams *)mxGetImagData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)));\n";
          $ArrayCplxIndex++;
          $iCplx++;
      }
    next;
  }
  
  
  if(/--mdlOutputsPortWidthDeclaration--/) {
    if($flagDynSize == 1){
      print OUT "    const int_T        y_width = ssGetOutputPortWidth(S,0);\n";
      print OUT "    const int_T        u_width = ssGetInputPortWidth(S,0);\n";
    }
    next;
  }


  if(/--mdlOutputFunctionCall--/){
    print OUT "    $fcnCallOutput\n";
    next;
  }

  ##############
  # mdlUpdate #
  ##############

  if(/--Define_MDL_UPDATE--/){
    if($NumDiscStates){
   print OUT "#define MDL_UPDATE  /* Change to #undef to remove function */\n"; 
   print OUT "/* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {\n";
      }
    next;
  }
  if(/--mdlUpdateInputDataTypeDeclaration--/){
   if ($NumDiscStates) {
      print OUT "    real_T         *xD  = ssGetDiscStates(S);\n";
      for($i=0;$i<$NumberOfInputPorts; $i++){
       if($InDataType[$i] =~ /\bfixpt\b/) {
         print OUT "    const DTypeId  *$InPortName[$i]  = (const DTypeId*) ssGetInputPortSignal(S,$i);\n";
        } else {
         print OUT "    const $InDataType[$i]   *$InPortName[$i]  = (const $InDataType[$i]*) ssGetInputPortSignal(S,$i);\n";
       }
      }
   } 
   next;
  }

  if(/--mdlUpdateOutputDataTypeDeclaration--/) {
    if ($NumDiscStates) {
      for($i=0;$i<$NumberOfOutputPorts; $i++){
       if($OutDataType[$i] =~ /\bfixpt\b/) {
        print OUT "    DTypeId        *$OutPortName[$i]  = (DTypeId *)ssGetOutputPortRealSignal(S,$i);\n";
       } else {
        print OUT "    $OutDataType[$i]        *$OutPortName[$i]  = ($OutDataType[$i] *)ssGetOutputPortRealSignal(S,$i);\n";
       } 
      }
    }
    next; 
  }
  if(/--mdlUpdateNumParams--/) {
    if ($NumDiscStates) {
      for($i=0; $i < $NumParams ; $i++){
	print OUT "    const int_T   p_width$i  = mxGetNumberOfElements(PARAM_DEF$i(S));\n";
      }
    for($i=0; $i < $NumParams ; $i++) {
	if($ParameterComplexity[$i]  =~ /COMPLEX_NO/) {
	  print OUT "    const $ParameterDataType[$i]  *$ParameterName[$i]  = mxGetData(PARAM_DEF$i(S));\n";
	}
    }
    
    @ArrayOfComplexParamsDataType = ();
    @ArrayCplxIndex = (); 
    local $k = 0;
    for($i=0; $i < $NumParams ; $i++) {
     if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
       print OUT "    $ParameterDataType[$i]       $ParameterName[$i]" . "Cplx;\n";
       print OUT "    $ParameterDataType[$i]       *$ParameterName[$i] = &$ParameterName[$i]" ."Cplx;\n";
       $ArrayOfComplexParamsDataType[$k] = $ParameterDataType[$i];
       $ArrayCplxIndex[$k] = $i;
       $k++;
       }
     }
     local $iCplx = 0;
     foreach $ArrCplxParams (@ArrayOfComplexParamsDataType){
       $ArrCplxParams =~ s/^c//;
       print OUT "    $ParameterName[$ArrayCplxIndex[$iCplx]]" . "Cplx" . ".re      = (*($ArrCplxParams *)mxGetData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)));\n";
       print OUT "    $ParameterName[$ArrayCplxIndex[$iCplx]]" . "Cplx" . ".im      = (*($ArrCplxParams *)mxGetImagData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)));\n";
       $ArrayCplxIndex++;
       $iCplx++;
     }

    if($flagDynSize == 1){
	print OUT "    const int_T     y_width = ssGetOutputPortWidth(S,0);\n";
	print OUT "    const int_T     u_width = ssGetInputPortWidth(S,0);\n";
      }
   }
    next;
  }

  if(/--mdlUpdateFunctionCall--/){
    if ($NumDiscStates) {
      print OUT "    $fcnCallUpdate";
      print OUT "\n}\n";
    }
    next;
  } 

  ##################
  # mdlDerivatives #
  ##################

  if(/--Define_MDL_DERIVATIVES--/){
    if($NumContStates){
      print OUT "#define MDL_DERIVATIVES  /* Change to #undef to remove function */\n"; 
      print OUT "/* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {\n";
    }
  next;
  }
  if(/--mdlDerivativesInputDataTypeDeclaration--/){
   if($NumContStates){
    for($i=0;$i<$NumberOfInputPorts; $i++){
      if($InDataType[$i] =~ /\bfixpt\b/) {
	print OUT "    const DTypeId  *$InPortName[$i]  = (const DTypeId*) ssGetInputPortSignal(S,$i);\n";
      } else {
	print OUT "    const $InDataType[$i]   *$InPortName[$i]  = (const $InDataType[$i]*) ssGetInputPortSignal(S,$i);\n";
      }
    }
     print OUT "    real_T         *dx  = ssGetdX(S);\n";
     print OUT "    real_T         *xC  = ssGetContStates(S);\n";
   }
   next;
  }

  if(/--mdlDerivativesOutputDataTypeDeclaration--/) {
    if($NumContStates){
      for($i=0;$i<$NumberOfOutputPorts; $i++){
	if($OutDataType[$i] =~ /\bfixpt\b/) {
	  print OUT "    DTypeId        *$OutPortName[$i]  =  (DTypeId *)ssGetOutputPortRealSignal(S,$i);\n";
	} else {
	  print OUT "    $OutDataType[$i]        *$OutPortName[$i]  = ($OutDataType[$i] *) ssGetOutputPortRealSignal(S,$i);\n";
	}
      }
    }
    next;
  }
  if(/--mdlDerivativesNumParams--/) {
   if($NumContStates){
      for($i=0; $i < $NumParams ; $i++){
	print OUT "    const int_T   p_width$i  = mxGetNumberOfElements(PARAM_DEF$i(S));\n";
      }

    for($i=0; $i < $NumParams ; $i++) {
     if($ParameterComplexity[$i]  =~ /COMPLEX_NO/) {
       print OUT "    const $ParameterDataType[$i]  *$ParameterName[$i]  = mxGetData(PARAM_DEF$i(S));\n";
     }
   }
    
    @ArrayOfComplexParamsDataType = ();
    @ArrayCplxIndex = (); 
    local $k = 0;
    for($i=0; $i < $NumParams ; $i++) {
       if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
	 print OUT "    $ParameterDataType[$i]       $ParameterName[$i]" . "Cplx;\n";
         print OUT "    $ParameterDataType[$i]       *$ParameterName[$i] = &$ParameterName[$i]" ."Cplx;\n";
         $ArrayOfComplexParamsDataType[$k] = $ParameterDataType[$i];
         $ArrayCplxIndex[$k] = $i;
         $k++;
       }
     }
     local $iCplx = 0;
     foreach $ArrCplxParams (@ArrayOfComplexParamsDataType){
       $ArrCplxParams =~ s/^c//;
       print OUT "    $ParameterName[$ArrayCplxIndex[$iCplx]]" . "Cplx" . ".re      = (*($ArrCplxParams *)mxGetData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)));\n";
       print OUT "    $ParameterName[$ArrayCplxIndex[$iCplx]]" . "Cplx" . ".im      = (*($ArrCplxParams *)mxGetImagData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)));\n";
       $ArrayCplxIndex++;
       $iCplx++;
    }

    if($flagDynSize == 1){
      print OUT "    const int_T    y_width = ssGetOutputPortWidth(S,0);\n";
      print OUT "    const int_T    u_width = ssGetInputPortWidth(S,0);\n";
    } 
  }
   next;
  }
  if(/--mdlDerivativesFunctionCall--/) {
    if($NumContStates){
     print OUT "    $fcnCallDerivatives\n}\n";
    }
    next;
  } 

   if(/--mdlTerminateDeclaration--/) {
     next;
    } 

   if(/--IncludeFixedPointDotC--/) {
     if($IsFixedBeingPropagated == 1) {
       print OUT "#include \"fixedpoint.c\"\n"; 
     }
     next;
    } 
    print OUT $_;
 
}    

close(IN);
close(OUT);
close(HC);
close(HTEMP);
close(HeaderF);
close(dStatesHandle);
close(CStatesHandle);


#################################
# Create the S-function Wrapper #
#################################

while (<INWrapper>) { 
 my($linewrapper) = $_;
 #Don't print Copyright
 if($. == 1 ) { next; }
 if($. == 2 ) { next; }

 if(/--WrapperIntroduction--/) {
    $strIntro = genWrapperIntro($timeString);
    print OUTWrapper "$strIntro\n"; 
    next;
  }
 
 if(/--IncludeHeaders--/) {
    print OUTWrapper @headerArray;
    next;
  }

 if(/--DefinesWidths--/){ 
   if($flagDynSize == 2) {
     print OUTWrapper "#define u_width $InRow[0]\n";
     print OUTWrapper "#define y_width $OutCol[0]\n";
   }
    next;
 }
 ######################
 # Extern declaration #
 ######################
 if(/--WrapperExternalDecalrations--/) {
   if($flagL){
     print OUTWrapper @externDeclarationsArray;
   }
    next;
 }
 
 if(/--mdlOutputsFcnPrototype--/) {
   print OUTWrapper "$fcnProtoTypeOutput\n";
   next; 
 }
 if(/--mdlOutputsFcnCode--/) {
   print OUTWrapper "@mdlOutputArray\n";
   next;  
 }

if(/--mdlUpdateFcnPrototype--/) {
 if ($NumDiscStates) {
  print OUTWrapper "\n/*
  * Updates function
  *
  */\n";
  print OUTWrapper "$fcnProtoTypeUpdate\n";
  print OUTWrapper "{
  /* %%%-SFUNWIZ_wrapper_Update_Changes_BEGIN --- EDIT HERE TO _END */\n";
 }
  next;
}

if(/--mdlUpdateFcnCode--/) {
 if ($NumDiscStates) {
   print OUTWrapper " @discStatesArray\n";
   print OUTWrapper "/* %%%-SFUNWIZ_wrapper_Update_Changes_END --- EDIT HERE TO _BEGIN */\n}\n";
 }
  next;
 }

if(/--mdlDerivativesFcnPrototype--/) {
 if($NumContStates){
  print OUTWrapper "\n/*
  *  Derivatives function
  *
  */\n";
  print OUTWrapper "$fcnProtoTypeDerivatives\n";
  print OUTWrapper "{\n/* %%%-SFUNWIZ_wrapper_Derivatives_Changes_BEGIN --- EDIT HERE TO _END */\n";
 }
 next;
}

 if(/--mdlDerivativesFcnCode--/) {
  if($NumContStates){
   print OUTWrapper "@contStatesArray\n";
   print OUTWrapper "/* %%%-SFUNWIZ_wrapper_Derivatives_Changes_END --- EDIT HERE TO _BEGIN */\n}"; 
  }
  next;
}

  print  OUTWrapper $_;
}
close(INWrapper);
close(OUTWrapper);

#################################
# Create the Wrapper TLC        #
#################################

if($CreateWrapperTLC) {

  $sfunNameWrapperTLC = $sFName . ".tlc";
  $sfNameWrapperTLC = $sFName . "_wrapper";
  
  $fcnCallOutputTLC =  genFunctionCallOutputTLC($NumParams, $NumDiscStates,$NumContStates, 
                                                $OutputfcnStr,$sFName ,  $flagDynSize);
  
  $stateDStrTLC = "%<pxd>";
  $fcnCallUpdateTLC = genFunctionCallTLC($NumParams,$NumDiscStates,$UpdatefcnStr,$stateDStrTLC, $sFName);
  
  $stateCStrTLC = "pxc";
  $fcnCallDerivativesTLC = genFunctionCallTLC($NumParams,$NumContStates,$DerivativesfcnStr,$stateCStrTLC ,$sFName);
  
  open(OUTWrapperTLC,">$sfunNameWrapperTLC") || die "Unable to create $sfunNameWrapperTLC Please check the directory permission\n";
  open(INWrapperTLC, "<$sfun_template_wrapperTLC") || die "Unable to open $sfun_template_wrapperTLC";
  
  while (<INWrapperTLC>) { 
    
    if($. == 1) {
      print OUTWrapperTLC  "%% File : $sFName.tlc" ;
    }
    
    if($. == 2) {
      print OUTWrapperTLC "%% Created: $timeString";
    }
    if($. == 6) {
      print OUTWrapperTLC  "%%   S-function \"$sfunName\"\.";
    }
    #Don't print Copyright
    if($. == 17 ) { next; }
    if($. == 18 ) { next; }

    if(/--ImplementsBlkDef--/) {
      print OUTWrapperTLC "%implements  $sFName \"C\"\n";
      next;
    }

    if(/--ExternDeclarationOutputTLC--/) {
       $inputSignalFixPtDataInfo ="";
       for($i = 0; $i < $NumberOfInputPorts ; $i++){
	 if($InDataType[$i] =~ /\bfixpt\b/) {
	   $inputSignalFixPtDataInfo = $inputSignalFixPtDataInfo . "\n  %assign u$i" . "DT = FixPt_GetInputDataType($i)";
	 }
       }
       $outputSignalFixPtDataInfo ="";
       for($i = 0; $i < $NumberOfOutputPorts ; $i++){
	 if($OutDataType[$i] =~ /\bfixpt\b/) {
	   $outputSignalFixPtDataInfo = $outputSignalFixPtDataInfo . "\n  %assign y$i" . "DT = FixPt_GetOutputDataType($i)";
	 }
       }

       print OUTWrapperTLC "  $inputSignalFixPtDataInfo";
       print OUTWrapperTLC "  $outputSignalFixPtDataInfo";
       print OUTWrapperTLC "\n  $wrapperExternDeclarationOutputTLC";
       next;  
     }

     if(/--ExternDeclarationUpdateTLC--/) {
       if($NumDiscStates> 0) {
	 print OUTWrapperTLC "  $wrapperExternDeclarationUpdateTLC";
       }
       next;
     }
     if(/--ExternDeclarationDerivativesTLC--/) {
       if($NumContStates> 0) {
	 print OUTWrapperTLC  "  $wrapperExternDeclarationDerivativesTLC";
       }
       next;
     }

     if(/--mdlInitializeConditionsTLC--/) {
       if ($NumDiscStates || $NumContStates ){
	 $methodInitTLC=get_mdlInitializeConditionsTLC_method($NumDiscStates ,$DStatesIC ,$NumContStates, $CStatesIC);
	 print  OUTWrapperTLC $methodInitTLC;
       }
       next;
     }

      if(/--mdlStartFunctionTLC--/) {
         if($GenerateStartFunction > 0) {
	  print  OUTWrapperTLC genStartFcnMethodsTLC();
	}
       next;
      }
     ###########
     # Outputs #
     ###########
     if(/--OutputsComment--/) {
       print OUTWrapperTLC  "   /* S-Function \"$sfNameWrapperTLC\" Block: %<Name> */\n";
       next;
     }
    if(/--OutputsPortsAddrTLC--/) {
      for($i=0; $i < $NumberOfInputPorts ; $i++){
	print OUTWrapperTLC "  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)\n";
       }   
      for($i=0; $i < $NumberOfOutputPorts ; $i++){
	print OUTWrapperTLC "  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)\n";
       }   
     next;
     }

     # DStates
     if(/--OutputsNumDiscStatesTLC--/) {
       if ($NumDiscStates > 0) {
	 print OUTWrapperTLC   "  %assign pxd = LibBlockDWorkAddr(DSTATE, \"\", \"\", 0)\n";
       }
       next;
     }
     if(/--OutputsNumParamsTLC--/) {
       $n = 1;
       for($i=0; $i < $NumParams ; $i++){
	 print OUTWrapperTLC "  %assign nelements$n = LibBlockParameterSize(P$n)\n";
	 print OUTWrapperTLC "  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]\n";
 $paramDeclarationTLC = "%if (param_width$n) > 1
     %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n)
   %else
     %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
   %endif";
	 print OUTWrapperTLC "  $paramDeclarationTLC\n";
	 $n++; 
       }
       next;
     }
     # Port Widths
     if(/--OutputsPortWidthsTLC--/) {
       if($NumberOfOutputPorts > 0) {
	 print  OUTWrapperTLC  "  %assign py_width = LibBlockOutputSignalWidth(0)\n";
	 print  OUTWrapperTLC  "  %assign pu_width = LibBlockInputSignalWidth(0)\n";
       }
       next;  
     }
     # CStates
     if(/--OutputsCodeAndNumContStatesTLC--/) {
       if($NumContStates > 0) {
	 print  OUTWrapperTLC " { \n    real_T *pxc = %<RTMGet(\"ContStates\")>;\n    $fcnCallOutputTLC  }";
       } else {
	 print OUTWrapperTLC   "  $fcnCallOutputTLC";
       }
       next;
     }

     ###########
     # Update  #
     ###########
     if(/--UpdateFunctionTLC--/) {
       if($NumDiscStates> 0){
	 $bFcn = getBodyFunctionUpdateTLC($NumParams, $sfNameWrapperTLC, $fcnCallUpdateTLC);
	 print  OUTWrapperTLC  $bFcn;
       }
       next;
     }
     ###############
     # Derivatives #
     ###############
     if(/--DerivativesFunctionTLC--/) {
       if($NumContStates> 0){
	 $bFcn =  getBodyFunctionDerivativesTLC($NumParams, $sfNameWrapperTLC, $fcnCallDerivativesTLC);
	 print  OUTWrapperTLC  $bFcn;
       }
       next;
     }
     ###############
     # Terminate   #
     ###############
     if(/--TerminateFunctionTLC--/) {
       if($GenerateTerminateFunction > 0) {
	 print  OUTWrapperTLC genTerminateFcnMethodsTLC();
       }
      next;
     }
     if(/--EOF--/) {
       print OUTWrapperTLC  "\n%% [EOF] $sfunNameWrapperTLC";
       next;
     }

     print  OUTWrapperTLC $_;
   }

   close(INWrapperTLC);
   close(OUTWrapperTLC);

###########################################################################
# Create the RTWMAKECFG.M file for use with RTW_C.M.
# This file looks in the current folder for <sfunction>__SFB__.mat files
# that contain configuration information for any additional library paths,
# source paths, include paths to be added to the build process.
###########################################################################
$ErrMsgCouldNotOpenRTWMAKECFGFileForRead = 
"Could not open rtwmakecfg.m to read ".
"even though it exists in the current folder.".
"Please check to see that the file is a readable ".
"text file. Please also check the read permissions on ".
"the file. Simply removing the file from the current ".
"folder should solve the problem.";

$ErrMsgCouldNotOpenRTWMAKECFGFileForWrite = 
    "Could not open rtwmakecfg.m to write.".
    "Please check to see that the folder has write permissions.";

$titleForRTWMAKECFG = "
function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to rtw make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following field:
%     makeInfo.includePath - cell array containing additional include
%                            directories. Those directories will be
%                            expanded into include instructions of rtw
%                            generated make files.
%
%     makeInfo.sourcePath  - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.
makeInfo.includePath = {};
makeInfo.sourcePath  = {};

";

$sfBuilderInsertTag = "\n%<S-Function Builder Insert tag. DO NOT REMOVE>\n";
$customBodyForRTWMAKECFG = 
$sfBuilderInsertTag."
sfBuilderBlocksByMaskType = find_system(bdroot,'MaskType','S-Function Builder');
sfBuilderBlocksByCallback = find_system(bdroot,'OpenFcn','sfunctionwizard(gcbh)');
sfBuilderBlocks = {sfBuilderBlocksByMaskType{:} sfBuilderBlocksByCallback{:}};
sfBuilderBlocks = unique(sfBuilderBlocks);
if isempty(sfBuilderBlocks)
   return;
end
for idx = 1:length(sfBuilderBlocks)
   sfBuilderBlockNameMATFile{idx} = get_param(sfBuilderBlocks{idx},'FunctionName');
   sfBuilderBlockNameMATFile{idx} = ['.' filesep 'SFB__' char(sfBuilderBlockNameMATFile{idx}) '__SFB.mat'];
end
sfBuilderBlockNameMATFile = unique(sfBuilderBlockNameMATFile);
for idx = 1:length(sfBuilderBlockNameMATFile)
   if exist(sfBuilderBlockNameMATFile{idx})
      loadedData = load(sfBuilderBlockNameMATFile{idx});
      if isfield(loadedData,'SFBInfoStruct')
         makeInfo = UpdateMakeInfo(makeInfo,loadedData.SFBInfoStruct);
         clear loadedData;
      end
   end
end
";
$sfBuilderUpdateMakeInfoFcn = "
function updatedMakeInfo = UpdateMakeInfo(makeInfo,SFBInfoStruct)
updatedMakeInfo = {};
if isfield(makeInfo,'includePath')
   if isfield(SFBInfoStruct,'includePath')
      updatedMakeInfo.includePath = {makeInfo.includePath{:} SFBInfoStruct.includePath{:}};
   else
      updatedMakeInfo.includePath = {makeInfo.includePath{:}};
   end
end
if isfield(makeInfo,'sourcePath')
   if isfield(SFBInfoStruct,'sourcePath')
      updatedMakeInfo.sourcePath = {makeInfo.sourcePath{:} SFBInfoStruct.sourcePath{:}};
   else
      updatedMakeInfo.sourcePath = {makeInfo.sourcePath{:}};
   end
end
if isfield(SFBInfoStruct,'additionalLibraries')
   % Copy over library and object files from their source folders to a
   % folder one folder above the *_target_rtw/ folder
   for idx=1:length(SFBInfoStruct.additionalLibraries)
      try
         if ~copyfile(SFBInfoStruct.additionalLibraries{idx})
            warning('Simulink:SFBuilder:rtwmakecfgCopyFailed', ...
                    sprintf('failed to copy %s to the current folder %s\\n',...
                    SFBInfoStruct.additionalLibraries{idx}, pwd));
         end
      catch %Try catch is to avoid any hard errors due to copyfile
      end
   end
end
";

$fileName = "rtwmakecfg.m";

if ( -f $fileName ) {

    open readHandle,"<$fileName" or die $ErrMsgCouldNotOpenRTWMAKECFGFileForRead;
    $fileData = join("",(<readHandle>));
    close(readHandle);
    $sfBuilderTagExists = grep(/$sfBuilderInsertTag/,$fileData);
    if ($sfBuilderTagExists < 1) {
        @splitOnFunction = split(/\n\s*function|^\s*function/,$fileData);
        $initComments    = shift @splitOnFunction;
        $insertRogue     = "\n%inserting rogue gene into string\n";
        $rtwmakecfgBody  = shift @splitOnFunction;
        $rtwmakecfgBody .= $customBodyForRTWMAKECFG.$sfBuilderUpdateMakeInfoFcn;
        unshift(@splitOnFunction,(($initComments eq '')?"\b":$initComments,$rtwmakecfgBody));
        $toPrint = join("\nfunction ",@splitOnFunction);

        open writeHandle,">$fileName" or die $ErrMsgCouldNotOpenRTWMAKECFGFileForWrite;
        print writeHandle $toPrint;
        close(writeHandle);
    }

} else {

    open writeHandle,">$fileName" or die $ErrMsgCouldNotOpenRTWMAKECFGFileForWrite;
    print writeHandle $titleForRTWMAKECFG.$customBodyForRTWMAKECFG.$sfBuilderUpdateMakeInfoFcn;
    close(writeHandle);

}


}

 ###################
 #Local functions  #
 ###################
 sub get_parameters_declaration {
 ($NumParams) =  @_;

 if ($NumParams){
 $declareNumParams = 
 "    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
      #if defined(MATLAB_MEX_FILE)
	if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
	  mdlCheckParameters(S);
	  if (ssGetErrorStatus(S) != NULL) {
	    return;
	  }
	 } else {
	   return; /* Parameter mismatch will be reported by Simulink */
	 }
      #endif\n";
 }
 else{

 $declareNumParams= "    ssSetNumSFcnParams(S, NPARAMS);
     if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
	 return; /* Parameter mismatch will be reported by Simulink */
     }\n";
 }
 return $declareNumParams;
 }

 sub get_mdlCheckParameters_method 
 {
   #(xxx) make this code into data driven table
   $checkparams = "";
   local $i;
   for($i=0; $i < $NumParams ; $i++){
     # parameter is the sample time
     if($ParameterName[$i] =~  /\b$sampleTime\b/){
       $ErrorStringParam = "Sample time parameter $ParameterName[$i]" .  " must be of type double";
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!mxIsDouble(pVal$i)) {
	    ssSetErrorStatus(S,\"$ErrorStringParam\");
	    return; 
	  }
	 }";
     }
     # Double parameters
     if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\breal_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_DOUBLE(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
     # Double Complex parameters
    if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcreal_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_DOUBLE_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
    #Single parameters
    if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\breal32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_SINGLE(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
    #Single Complex parameters
    if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcreal32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_SINGLE_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
    #Int8 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT8(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Int8 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT8_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }


    #Int16 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT16(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Int16 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT16_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Int32 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT32(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Int32 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT32_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Uint8 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\buint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT8(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Uint8 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcuint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT8_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Uint16 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\buint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT16(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Uint16 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcuint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT16_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Uint32 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\buint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT32(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Uint32 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcuint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT32_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Boolean parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bboolean_T\b/) {
       $checkparams =   $checkparams . "
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_BOOLEAN(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }


   }
   $paramVector = "char paramVector[] ={'1'";
   local $n = 2;
   for($i=1; $i < $NumParams ; $i++){
     $paramVector = $paramVector . ",'$n'";
     $n++;
   }
   $paramVector = $paramVector ."};";

 $Body = "#define MDL_CHECK_PARAMETERS
 #if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
   /* Function: mdlCheckParameters =============================================
     * Abstract:
     *    Validate our parameters to verify they are okay.
     */
    static void mdlCheckParameters(SimStruct *S)
    {
     #define PrmNumPos 46
     int paramIndex = 0;
     bool validParam = false;
     $paramVector
     static char parameterErrorMsg[] =\"The data type and/or complexity of parameter    does not match the information \"
     \"specified in the S-function Builder dialog. For non-double parameters you will need to cast them using int8, int16,\"
     \"int32, uint8, uint16, uint32 or boolean.\"; 

     /* All parameters must match the S-function Builder Dialog */
     $checkparams
     EXIT_POINT:
      if (validParam) {
	  parameterErrorMsg[PrmNumPos] = paramVector[paramIndex];
	  ssSetErrorStatus(S,parameterErrorMsg);
      }
	return;
    }
 #endif /* MDL_CHECK_PARAMETERS */\n";

 return $Body;
 }

 sub get_mdlInitializeConditions_method 
 {

 ($NumDStates, $dIC, $NumCStates, $cIC ) =  @_;

 $dIC =~ s/\s+/,/;
 $cIC =~ s/\s+/,/;
 $dIC =~ s/,{1,}/,/;
 $cIC =~ s/,{1,}/,/;

 @vectordIC = split(',', $dIC);
 @vectorcIC = split(',', $cIC);

 $IsInitialConditionNotUsedAsParamter = 1;
 if($NumDStates){
   $declareDInitC = "real_T *xD   = ssGetRealDiscStates(S);";
  
   for($i=0; $i < $NumDStates; $i++){
     for($k=0;$k<$NumParams; $k++){
       if($ParameterName[$k] =~  /\b$vectordIC[$i]\b/){
	 if($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
	   $initD =  "$initD\n    xD[$i] =  *mxGetPr(ssGetSFcnParam(S, $k));";  
	 } else { 
	   $initD =  "$initD\n    xD[$i] = 0.0; /* State must be of type double */";  
	 }
	 $IsInitialConditionNotUsedAsParamter = 0;
	 last;
	} else {
	  $IsInitialConditionNotUsedAsParamter = 1;
	}
     }
     if( $IsInitialConditionNotUsedAsParamter) {
       $initD =  "$initD\n    xD[$i] =  $vectordIC[$i];";  
     }
   }
 }

 $IsInitialConditionNotUsedAsParamterForContStates = 1;

 if($NumCStates){
  $declareCInitC = "real_T *xC   = ssGetContStates(S);";

   for($i=0; $i < $NumCStates; $i++){
     for($k=0;$k<$NumParams; $k++){
       if($ParameterName[$k] =~  /\b$vectorcIC[$i]\b/){
	 if($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
	   $initC =  "$initC\n    xC[$i] = *mxGetPr(ssGetSFcnParam(S, $k));";  
	 } else {
	   $initC =  "$initC\n    xC[$i] = 0.0; /* State must be of type double */";  
	 }
	 $IsInitialConditionNotUsedAsParamterForContStates = 0;
	 last;
       } else {
	 $IsInitialConditionNotUsedAsParamterForContStates = 1;
       }
     }
     if($IsInitialConditionNotUsedAsParamterForContStates) {
       $initC =  "$initC\n    xC[$i] =  $vectorcIC[$i];";  
     }
   }
}

 $modymdlInitCond ="#define MDL_INITIALIZE_CONDITIONS
 /* Function: mdlInitializeConditions ========================================
  * Abstract:
  *    Initialize the states
  */
 static void mdlInitializeConditions(SimStruct *S)
 {
   $declareDInitC
   $declareCInitC
    $initD
    $initC
 }";

 return $modymdlInitCond;
 }

 sub get_mdlInitializeConditionsTLC_method {

 ($NumDStates, $dIC, $NumCStates, $cIC ) =  @_;
 @vectordIC = split(',',$dIC);
 @vectorcIC = split(',',$cIC);

 if($NumDStates){  
   $n = 1;
   for($i=0; $i < $NumDStates; $i++){
     for($k=0;$k<$NumParams; $k++){
       if($ParameterName[$k] =~  /\b$vectordIC[$i]\b/){
	 if($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
	   $pinit = "%<pp" . $n . ">";
	   $_ = $dIC;
	   $dIC =~ s/$ParameterName[$k]/$pinit/e;
   $paramNeeded = " $paramNeeded\n   %assign nelements$n = LibBlockParameterSize(P$n)
   %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]
   %if (param_width$n) > 1
     %assign pp$n = LibBlockMatrixParameter(P$n)
   %else
     %assign pp$n = LibBlockParameter(P$n, \"\", \"\", 0)
   %endif\n";
	 }
       }
       $n++;
     }
   }

  $discreteInitCondDec = "real_T initVector[$NumDStates] = {$dIC};";

  $discStatesCode = "{\n"."$discreteInitCondDec
   $paramNeeded"."%assign rollVars = [\"<dwork>/DSTATE\"]
   %assign rollRegions = [0:%<LibBlockDWorkWidth(DSTATE)-1>]
   %roll sigIdx = rollRegions, lcv = 1, block, \"Roller\", rollVars
     %if %<LibBlockDWorkWidth(DSTATE)> == 1
       %<LibBlockDWork(DSTATE, \"\", lcv, sigIdx)> = initVector[0];
      %else
       %<LibBlockDWork(DSTATE, \"\", lcv, sigIdx)> = initVector[%<lcv>];
      %endif
   %endroll"."\n}";
 }

 @vectorcIC = split(',|\s+',$cIC);
 $contStatesCode = "real_T *xC   = %<RTMGet(\"ContStates\")>;";
 if($NumCStates){  
   $n = 1;
   for($i=0; $i < $NumCStates; $i++){
     for($k=0;$k<$NumParams; $k++){
       if($ParameterName[$k] =~  /\b$vectorcIC[$i]\b/){
	 if($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
	   $paramInit = "%<p_c" . $n . ">";
	   $vectorcIC[$i] = $paramInit;
   $contParamNeeded = " $contParamNeeded\n   %assign pnelements$n = LibBlockParameterSize(P$n)
   %assign cparam_width$n = pnelements$n\[0\] * pnelements$n\[1\]
   %if (cparam_width$n) > 1
     %assign p_c$n = LibBlockMatrixParameter(P$n)
   %else
     %assign p_c$n = LibBlockParameter(P$n, \"\", \"\", 0)
   %endif\n";
	 }
       }
       $n++;
     }
   }

   for($i=0; $i < $NumCStates; $i++) {
     $initCondDec =  "$initCondDec\n    xC[$i] =  $vectorcIC[$i];";  
   }

   $contStatesBody = "{ 
   $contStatesCode
   $contParamNeeded
   $initCondDec
  }";
 }
 $mdlInitCondTLC = "%% InitializeConditions =========================================================
 %%
 %function InitializeConditions(block, system) Output
  /* %<Type> Block: %<Name> */
  $discStatesCode
  $contStatesBody
 %endfunction";

 return  $mdlInitCondTLC;
 }

 sub genIntro {

 my($intro);

 $intro = " *
  *
  *   \--- THIS FILE GENERATED BY S-FUNCTION BUILDER: 2.0 \---
  *
  *   This file is an S-function produced by the S-Function
  *   Builder which only recognizes certain fields.  Changes made
  *   outside these fields will be lost the next time the block is
  *   used to load, edit, and resave this file. This file will be overwritten
  *   by the S-function Builder block. If you want to edit this file by hand, 
  *   you must change it only in the area defined as:  
  *
  *        %%%-SFUNWIZ_defines_Changes_BEGIN
  *        #define NAME 'replacement text' 
  *        %%% SFUNWIZ_defines_Changes_END
  *
  *   DO NOT change NAME--Change the 'replacement text' only.
  *
  *   For better compatibility with the Real-Time Workshop, the
  *   \"wrapper\" S-function technique is used.  This is discussed
  *   in the Real-Time Workshop User\'s Manual in the Chapter titled,
  *   \"Wrapper S-functions\".
  *
  *  -------------------------------------------------------------------------
  * | See matlabroot/simulink/src/sfuntmpl_doc.c for a more detailed template |
  *  ------------------------------------------------------------------------- ";

 return $intro;
 }

 sub genWrapperIntro {

 my($wrapperintro);

 $wrapperintro = "/*
  *
  *   \--- THIS FILE GENERATED BY S-FUNCTION BUILDER: 2.0 \---
  *
  *   This file is a wrapper S-function produced by the S-Function
  *   Builder which only recognizes certain fields.  Changes made
  *   outside these fields will be lost the next time the block is
  *   used to load, edit, and resave this file. This file will be overwritten
  *   by the S-function Builder block. If you want to edit this file by hand, 
  *   you must change it only in the area defined as:  
  *
  *        %%%-SFUNWIZ_wrapper_XXXXX_Changes_BEGIN 
  *            Your Changes go here
  *        %%%-SFUNWIZ_wrapper_XXXXXX_Changes_END
  *
  *   For better compatibility with the Real-Time Workshop, the
  *   \"wrapper\" S-function technique is used.  This is discussed
  *   in the Real-Time Workshop User\'s Manual in the Chapter titled,
  *   \"Wrapper S-functions\".
  *
  *   Created: $timeString
  */";

 return $wrapperintro;
 }

 ############################################################################
 # Outputs Function call i.e:                                               # 
 #  extern void sys_Outputs_wrapper(const real_T *$InPortName[0],           #
 #                             const real_T *$OutPortName[0],               #
 #                             real_T  *param0,  const real_T  *param1);    #
 ############################################################################
 sub genOutputWrapper {

 ($NumParams, $NumDStates, $NumCStates,$fcnType, $sfName, $flagDynSize, $inDType, $outDType, $isTLC) =  @_;
 local $i, $n,$fcnType, $useComma;
 my( $declareU);
 my( $declareY);
 my($tempString);
 my($commaStr);

  # port widths
  if($flagDynSize == 1){
    $portwidths = ",\n\t\t\t     const int_T y_width, const int_T u_width";
  } else {
    $portwidths = "";
   }
 $fcnPrototypeRequired ="void ". $sfName . "_". $fcnType . "_wrapper(";
  $commaStr = "";
  if( ($NumberOfInputPorts > 0) ||  ($NumberOfOutputPorts > 0)) {
    $commaStr = ",";
  }
 ##########
 # inputs #
 ##########
 if( $NumberOfInputPorts > 0) {
   if($InDataType[0] =~ /\bfixpt\b/) {
     if($isTLC) {
       $declareU ="const  %<u0DT.NativeType> *$InPortName[0]";
     } else {
       $declareU ="const DTypeId *$InPortName[0]";
     }
   } else {
    $declareU ="const $InDataType[0] *$InPortName[0]";
   }
 }


 for($i=1;$i<$NumberOfInputPorts; $i++){
  if($InDataType[$i] =~ /\bfixpt\b/) {
    if($isTLC) {
      $declareU =  $declareU . ",\n$EMPTY_SPACE const  %<u$i" . "DT.NativeType> *$InPortName[$i]"; 
    } else {
      $declareU =  $declareU . ",\n$EMPTY_SPACE const  DTypeId *$InPortName[$i]"; 
    }
  } else {
    $declareU =  $declareU . ",\n$EMPTY_SPACE const $InDataType[$i] *$InPortName[$i]"; 
  }
 }

 # pad the $declareU with extra space so we can get nice format
 if( ($NumberOfInputPorts > 0) &&  ($NumberOfOutputPorts > 0) ||
     (($NumParams > 0  ||  $NumDStates > 0 && $NumCStates > 0 )) ) {
     $declareU = $declareU . ",\n$EMPTY_SPACE ";
 }
 ###########
 # outputs #
 ###########
 if( $NumberOfOutputPorts > 0) {
  if($OutDataType[0] =~ /\bfixpt\b/) {
     if($isTLC) {
       $declareY = "%<y0DT.NativeType>" . " *$OutPortName[0]";
     } else {
       $declareY = "DTypeId" . " *$OutPortName[0]";
     }
   } else {
   $declareY = $OutDataType[0] . " *$OutPortName[0]";
  }
 }
 for($i=1;$i<$NumberOfOutputPorts; $i++){
  if($OutDataType[$i] =~ /\bfixpt\b/) {
     if($isTLC) {
       $declareY =  $declareY . ",\n" . "$EMPTY_SPACE %<y$i" . "DT.NativeType> *$OutPortName[$i]";
     } else {
       $declareY =  $declareY . ",\n" . "$EMPTY_SPACE DTypeId *$OutPortName[$i]";
     }
  } else {
    $declareY =  $declareY . ",\n" . "$EMPTY_SPACE $OutDataType[$i] *$OutPortName[$i]";
  }
 }

 $fcnPrototypeRequired = $fcnPrototypeRequired . 
			 $declareU .
			 $declareY;
 $n = 0;
 if($NumParams == 0 &&  $NumDStates == 0 && $NumCStates ==0 ) {
    $fcnPrototype = $fcnPrototypeRequired . $portwidths . ")";

 } else {

     $varDStates =     "const real_T  *xD";
     $varCStates =     "const real_T *xC";
     $varParams = "";
     if($NumParams){
       $emptySpace = "                              ";
       ##(xxx) Fixed for zero outputs
       if($NumberOfOutputPorts > 0) { $useComma = ",";}
	 for($i=0; $i < $NumParams - 1 ; $i++){
	     $varParams = $varParams . "$EMPTY_SPACE const $ParameterDataType[$i]  *$ParameterName[$i], const int_T  p_width$i, \n";  
	     $n = $i+ 1;     
	   }
	 if(($NumDStates > 0) && ($NumCStates == 0)){
	     ##(xxx) Fixed for zero outputs
	     $fcnPrototype = "$fcnPrototypeRequired $useComma
			      $varDStates,\n$varParams $EMPTY_SPACE1    const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n";

	 } elsif(($NumDStates == 0) && ($NumCStates > 0)) { 
	     ##(xxx) Fixed for zero outputs
	     $fcnPrototype = "$fcnPrototypeRequired $useComma
			   $varCStates,\n$varParams $EMPTY_SPACE1    const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n"; 

	 } elsif(($NumDStates > 0) && ($NumCStates > 0)) { 
	     $fcnPrototype = "$fcnPrototypeRequired $useComma
			              $varDStates $useComma
                          $varCStates,\n$varParams $EMPTY_SPACE1    const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n";
                             
	}
	elsif(($NumDStates == 0) && ($NumCStates == 0)){ 
	  if ($NumParams == 1) {
	      $fcnPrototype = "$fcnPrototypeRequired" . "$commaStr 
                           const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n";                            

	  } else {
	    $fcnPrototype = "$fcnPrototypeRequired  $commaStr \n$varParams $EMPTY_SPACE1    const $ParameterDataType[$n]  *$ParameterName[$n],  const int_T p_width$n";         

	  }
	}
	
    }else {
	if(($NumDStates > 0) && ($NumCStates == 0)){
	    $fcnPrototype = "$fcnPrototypeRequired,
                          $varDStates";
	} elsif(($NumDStates == 0) && ($NumCStates > 0)) { 
	    $fcnPrototype = "$fcnPrototypeRequired,
                          $varCStates";
	} elsif(($NumDStates > 0) && ($NumCStates > 0)) { 
	    $fcnPrototype = "$fcnPrototypeRequired,
                          $varDStates,
                          $varCStates";
	}
    }
    $fcnPrototype = $fcnPrototype . $portwidths . ")";
}
return $fcnPrototype;

}

############################################################################
# States Function call i.e:                                                # 
#  extern void sys_Derivatives_wrapper(const real_T *$InPortName[0],       #
#                             const real_T *$OutPortName[0],               #
#                             real_T      *xD,                             #  
#                             real_T  *param0,  const real_T  *param1);    #
############################################################################
sub genStatesWrapper {

($UpNumParams, $UpNumDStates, $UpfcnType, $state,  $sfName, $inDType, $outDType, $isTLC) =  @_;
local $Upi, $Upn, $useComma;
my($commaStr);
 # port widths
 if($flagDynSize == 1){
   $portwidths = ",\n\t\t\t     const int_T y_width, const int_T u_width";
 } else {
   $portwidths = "";
  }

$UpfcnPrototypeRequired ="void ". $sfName . "_". $UpfcnType . "_wrapper(";
if( ($NumberOfInputPorts > 0) ||  ($NumberOfOutputPorts > 0)) {
   $commaStr = ",";
 }
##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
  if($InDataType[0] =~ /\bfixpt\b/) {
    if($isTLC) {
      $UpdeclareU ="const  %<u0DT.NativeType> *$InPortName[0]"; 
    } else {
      $UpdeclareU ="const DTypeId *$InPortName[0]"; 
    }
  } else {
    $UpdeclareU ="const $InDataType[0] *$InPortName[0]"; 
  }
}

for($i=1;$i<$NumberOfInputPorts; $i++){
  if($InDataType[$i] =~ /\bfixpt\b/) {
    if($isTLC) {
      $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE const  %<u$i" . "DT.NativeType> *$InPortName[$i]";
    } else {
      $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE const DTypeId *$InPortName[$i]";
    }
  } else {
    $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE const $InDataType[$i] *$InPortName[$i]";
  }
}

# pad the $declareU with extra space so we can get nice format
if( ($NumberOfInputPorts > 0) &&  ($NumberOfOutputPorts > 0) ||
    (($NumParams > 0  ||  $NumDStates > 0 || $NumCStates > 0 )) ) {
  $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE ";
}

###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if($OutDataType[0] =~ /\bfixpt\b/) {
    if($isTLC) {
      $UpdeclareY ="const %<y0DT.NativeType>" . " *$OutPortName[0]";
    } else {
      $UpdeclareY ="const DTypeId" . " *$OutPortName[0]";
    }
 } else {
   $UpdeclareY ="const $OutDataType[0]" . " *$OutPortName[0]";
 }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
  if($OutDataType[$i] =~ /\bfixpt\b/) {
    if($isTLC) {
      $UpdeclareY =  $UpdeclareY . ",\n" . "$EMPTY_SPACE const %<y$i" . "DT.NativeType> *$OutPortName[$i]";
    } else {
      $UpdeclareY =  $UpdeclareY . ",\n" . "$EMPTY_SPACE const DTypeId *$OutPortName[$i]";
    }
  } else {
    $UpdeclareY =  $UpdeclareY . ",\n" . "$EMPTY_SPACE const $OutDataType[$i] *$OutPortName[$i]";
  }
}

if($state =~ /xC/) {
  $UpfcnPrototypeRequired = $UpfcnPrototypeRequired . 
                            $UpdeclareU .
                            $UpdeclareY . ",\n $EMPTY_SPACE" .
                            "real_T *dx";
  

} else {
  $UpfcnPrototypeRequired = $UpfcnPrototypeRequired . 
                            $UpdeclareU .
			    $UpdeclareY;
}


$Upn = 0;
if($UpNumParams == 0 &&  $UpNumDStates == 0) {
  $UpfcnPrototype = "$UpfcnPrototypeRequired" . " $portwidths" . ")"; 
  
} else {
    
  $UpvarDStates = "real_T *$state";
  
  $UpvarParams = "";
  if($NumberOfOutputPorts > 0) { $useComma = ",";}
  if($UpNumParams){
    for($Upi=0; $Upi < $UpNumParams - 1 ; $Upi++){
      $UpvarParams = $UpvarParams . "const $ParameterDataType[$Upi]  *$ParameterName[$Upi],  const int_T  p_width$Upi,\n $EMPTY_SPACE"; 

      $Upn = $Upi+ 1;     
    }
    if($UpNumDStates){
      if ($NumParams == 1) {
        ## (xxx)Fixed
	$UpfcnPrototype = "$UpfcnPrototypeRequired $useComma
                           $UpvarDStates, 
                          const $ParameterDataType[$Upn]  *$ParameterName[$Upn], const int_T  p_width$Upn";
                             
      } else {
        ## (xxx)Fixed
	$UpfcnPrototype = "$UpfcnPrototypeRequired $useComma
                          $UpvarDStates, 
                          $UpvarParams const $ParameterDataType[$Upn] *$ParameterName[$Upn], const int_T  p_width$Upn";
                             
      }

    } else { 
      if ($NumParams == 1) {
	$UpfcnPrototype = "$UpfcnPrototypeRequired" . " $commaStr
                          const $ParameterDataType[$Upn]  *$ParameterName[$Upn], const int_T p_width$Upn";

      } else {
	$UpfcnPrototype = "$UpfcnPrototypeRequired $commaStr $UpvarParams const $ParameterDataType[$Upn]  *$ParameterName[$Upn], const int_T p_width$Upn";

      }
    }
  }
  else {
   $UpfcnPrototype = "$UpfcnPrototypeRequired,
                          $UpvarDStates";


 }
 $UpfcnPrototype =  $UpfcnPrototype . 
                    $portwidths . ")";
}

return $UpfcnPrototype;

}
######################################
# Wrapper Outputs Fcn Call:          #
# sys_Update_wrapper(u, y, xD);      #
######################################
sub genFunctionCall {

($NParams, $NDStates, $fcnType, $state, $sfName) =  @_;
local $i, $n, $fcnType, $state;

 # port widths
 if($flagDynSize == 1){
   $portwidths = ", y_width, u_width";
 } else {
   $portwidths = "";
 }

$fcnCallRequired =$sfName. "_". $fcnType . "_wrapper(";

##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
  $declareU ="$InPortName[0]"; 
}

for($i=1;$i<$NumberOfInputPorts; $i++){
  $declareU =  $declareU  .  ", $InPortName[$i]";
}

###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if( $NumberOfInputPorts > 0) {
    $declareY = ", $OutPortName[0]";
  } else {
    $declareY = "$OutPortName[0]";
  }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
  $declareY =  $declareY . ", $OutPortName[$i]";
}

if ($state =~ /xC/) {
  $fcnCallRequired = $fcnCallRequired .
                     $declareU .
                     $declareY .
                     ",dx"; 
} else {
  $fcnCallRequired = $fcnCallRequired .
                     $declareU .
		     $declareY;

}

$n = 0;
if($NParams == 0 &&  $NDStates == 0) {
  $fcnCall = "$fcnCallRequired" . "$portwidths" . ");"; 
  
} else {
  
  $DStates =     $state;
  $Params = "";
  if($NParams){
    for($i=0; $i < $NParams - 1 ; $i++){
      $Params = $Params . 
	"$ParameterName[$i], p_width$i, "; 
      $n = $i+ 1;     
    }
    if($NDStates){
      $fcnCall = "$fcnCallRequired, " . "$DStates, $Params" . "$ParameterName[$n], " .  "p_width$n";
    } else { 
      $fcnCall = "$fcnCallRequired, " . "$Params" . "$ParameterName[$n], " . "p_width$n";
    }
  }
  else {
    $fcnCall = "$fcnCallRequired, " . "$DStates";
  }
  $fcnCall = $fcnCall . $portwidths .");";
}

return $fcnCall;

}

############################
# Wrapper Outputs Fcn Call #
############################
sub genFunctionCallOutput {

($NParams, $NDStates, $NCStates, $fcnType, $sfName, $flagDynSize) =  @_;
local $i, $n, $fcnType, $Params;

 # port widths
 if($flagDynSize == 1){
   $portwidths = ", y_width, u_width";
 } else {
   $portwidths = "";
  }

#$fcnCallRequired =$sfName. "_". $fcnType . "_wrapper(u, y";
$fcnCallRequired =$sfName. "_". $fcnType . "_wrapper(";
##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
  $declareU ="$InPortName[0]"; 
}

for($i=1;$i<$NumberOfInputPorts; $i++){
  $declareU =  $declareU .  ", $InPortName[$i]";
}

###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if( $NumberOfInputPorts > 0) {
    $declareY = ", $OutPortName[0]";
  } else {
    $declareY = "$OutPortName[0]";
  }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
  $declareY =  $declareY . ", $OutPortName[$i]";
}

$fcnCallRequired = $fcnCallRequired .
                   $declareU .
                   $declareY;

$n = 0;
if($NParams == 0 &&  $NDStates == 0 && $NCStates ==0) {
  $fcnCallOut = $fcnCallRequired . $portwidths . ");"; 
  
} else {
  
  $DStates = "xD";
  $CStates = "xC";
  $Params = "";
  if($NParams){
      for($i=0; $i < $NParams - 1 ; $i++){
	  $Params = $Params . 
	      "$ParameterName[$i], p_width$i, ";  
	  $n = $i+ 1;     
      }
      if(($NDStates > 0) && ($NCStates == 0)){
	  $fcnCallOut = "$fcnCallRequired, " . "$DStates, $Params" . "$ParameterName[$n], p_width$n";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired, " . "$CStates, $Params" . "$ParameterName[$n], p_width$n";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired, " . "$DStates,  $CStates, $Params" . "$ParameterName[$n] , p_width$n";
      }
      elsif(($NDStates == 0) && ($NCStates == 0)) { 
	  $fcnCallOut = "$fcnCallRequired, $Params" . "$ParameterName[$n], p_width$n";
      }
  } else {
      if(($NDStates > 0) && ($NCStates == 0)){
	  $fcnCallOut = "$fcnCallRequired, " . "$DStates";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired, " . "$CStates";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired, " . "$DStates, $CStates";
      }
  }
  $fcnCallOut = $fcnCallOut . $portwidths .");";
}  
return $fcnCallOut;

}


#########################################################################
# Wrapper Outputs Fcn Call for the warpper TLC:                         #
#                                                                       #  
# sys_Outputs_wrapper(%<pu>, %<py>, %<py_width>, %<pu_width>);  #
#                                                                       # 
#########################################################################
sub genFunctionCallOutputTLC {


($NParams, $NDStates, $NCStates, $fcnType, $sfName,  $flagDynSize) =  @_;
local $i, $n, $fcnType, $Params ,$DStates, $CStates;


 # Dynamic post widths
 if($flagDynSize == 1){
   $portwidths = ", %<py_width>, %<pu_width>";
 } else {
   $portwidths = "";
 }

$fcnCallRequired = $sfName . "_". $fcnType . "_wrapper(";
##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
  $declareU ="%<pu0>"; 
}

for($i=1;$i<$NumberOfInputPorts; $i++){
  $declareU =  $declareU . ", %<pu$i>";
}

###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if( $NumberOfInputPorts > 0) {
   $declareY =", %<py0>";
  } else {
    $declareY =" %<py0>";
  }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
  $declareY =  $declareY . "," . " %<py$i>";
}


$fcnCallRequired = $fcnCallRequired .  $declareU . $declareY;

$n = 1;
if($NParams == 0 &&  $NDStates == 0 && $NCStates ==0) {
  $fcnCallOutTLC = "$fcnCallRequired" . " $portwidths" . ");\n\n"; 
  
} else {
  
  $DStates = " %<pxd>";
  $CStates = "pxc";
  $Params = "";
  if($NParams){
      for($i=0; $i < $NParams - 1 ; $i++){
	  $n = $i + 1;     
	  $Params = $Params . 
	    " %<pp$n>, %<param_width$n>, "; 
	  $n++;
	}
      if(($NDStates > 0) && ($NCStates == 0)){
	$fcnCallOutTLC = "$fcnCallRequired, " . "$DStates, $Params" . "%<pp$n>, %<param_width$n>";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired, " . "$CStates, $Params" . "%<pp$n>, %<param_width$n>";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired, " . "$DStates,  $CStates, $Params" . "%<pp$n>, %<param_width$n>";
      }
      elsif(($NDStates == 0) && ($NCStates == 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired, $Params" . "%<pp$n>, %<param_width$n>";
      }
  } else {
      if(($NDStates > 0) && ($NCStates == 0)){
	$fcnCallOutTLC = "$fcnCallRequired, " . "$DStates";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired, " . "$CStates";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired, " . "$DStates, $CStates";
      }
  }
  $fcnCallOutTLC = $fcnCallOutTLC  . $portwidths . ");\n\n";
}  
return $fcnCallOutTLC;

}



###################
# FunctionCallTLC #
###################

sub genFunctionCallTLC {

($NParams, $NDStates, $fcnType, $state, $sfName) =  @_;
local $i, $n, $fcnType, $fcnCall;

 # Dynamic post widths
 if($flagDynSize == 1){
   $portwidths = ", %<py_width>, %<pu_width>";
 } else {
   $portwidths = "";
 }

$fcnCallRequired = $sfName . "_". $fcnType . "_wrapper(";
##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
  $declareU ="%<pu0>"; 
}

for($i=1;$i<$NumberOfInputPorts; $i++){
  $declareU =  $declareU . ", %<pu$i>";
}

###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if( $NumberOfInputPorts > 0) {
     $declareY =", %<py0>"; 
  } else {
     $declareY =" %<py0>"; 
  }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
  $declareY =  $declareY . "," . " %<py$i>";
}

$fcnCallRequired = $fcnCallRequired .  $declareU . $declareY;

if( $state =~ /pxc/){
 $fcnCallRequired =  $fcnCallRequired . ", dx";
}
$n = 1;
if($NParams == 0 &&  $NDStates == 0) {
  $fcnCall = "$fcnCallRequired" . "$portwidths". ");"; 
  
} else {
  
  $DStates =     $state;
  $Params = "";
  if($NParams){
    for($i=0; $i < $NParams - 1 ; $i++){
      $Params = $Params . 
	"%<pp$n>, %<param_width$n>, "; 
      $n++;
    }
    if($NDStates){
      $fcnCall = "$fcnCallRequired, " . "$DStates, $Params" . "%<pp$n>, %<param_width$n>";
    } else { 
      $fcnCall = "$fcnCallRequired, " . "$Params" . "%<pp$n>, %<param_width$n>";
    }
  }
  else {
   $fcnCall = "$fcnCallRequired, " . "$DStates";
  }
  $fcnCall = $fcnCall . $portwidths . ");";
}

return $fcnCall;

}



#####################################
# Generate the Update TLC function #
#####################################
sub getBodyFunctionUpdateTLC {

($NParams, $sfNameWrapperTLC, $fcnCallUpdateTLC) =   @_;
local $n,  $Body, $inportAddrInfo, $outportAddrInfo;
$Params = "";
$n = 1;
if($NParams){
 for($i=0; $i < $NParams; $i++){
  $Params = "$Params 
  %assign nelements$n = LibBlockParameterSize(P$n)
  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]  
  %if (param_width$n) > 1  
   %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n)
  %else  
   %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
  %endif";
  $n++;
  }
}
if($flagDynSize == 1){
  $WidthInfoTLC = "%assign py_width = LibBlockOutputSignalWidth(0)\n  %assign pu_width = LibBlockInputSignalWidth(0)";
}
$inportAddrInfo ="";
for($i = 0; $i < $NumberOfInputPorts ; $i++){
  $inportAddrInfo =   $inportAddrInfo . "\n  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)";
}
$outportAddrInfo ="";   
for($i=0; $i < $NumberOfOutputPorts ; $i++){
   $outportAddrInfo =  $outportAddrInfo . "\n  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)";
}   
$Body ="%% Function: Update ==========================================================
%% Abstract:
%%    Update
%%     
%%
%function Update(block, system) Output
    /* S-Function \"$sfNameWrapperTLC\" Block: %<Name> */
  $inportAddrInfo $outportAddrInfo
  %assign pxd = LibBlockDWorkAddr(DSTATE, \"\", \"\", 0)
  $WidthInfoTLC
  $Params\n
  $fcnCallUpdateTLC
  %%
%endfunction ";

return $Body;
}

#########################################
# Generate the Derivatives TLC function #
#########################################
sub getBodyFunctionDerivativesTLC {

($NParams, $sfNameWrapperTLC, $fcnCallDerivativesTLC) =   @_;
local $n,  $Body;
$Params = "";
$n = 1;
if($NParams){
 for($i=0; $i < $NParams; $i++){
  $Params = "$Params
  %assign nelements$n = LibBlockParameterSize(P$n)
  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]
  %if (param_width$n) > 1    
   %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n) 
  %else    
   %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
  %endif";
  $n++;
  }
}

if($flagDynSize == 1){
  $WidthInfoTLC = "%assign py_width = LibBlockOutputSignalWidth(0)\n  %assign pu_width = LibBlockInputSignalWidth(0)";
}
$inportAddrInfo ="";
for($i=0; $i < $NumberOfInputPorts ; $i++){
  $inportAddrInfo =   $inportAddrInfo . "\n  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)";
} 
$outportAddrInfo ="";  
for($i=0; $i < $NumberOfOutputPorts ; $i++){
   $outportAddrInfo =  $outportAddrInfo . "\n  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)";
}   
$Body ="\n%% Function: Derivatives ======================================================
%% Abstract:
%%      Derivatives
%%
%function Derivatives(block, system) Output
   /* S-Function \"$sfNameWrapperTLC\" Block: %<Name> */  

  $inportAddrInfo
  $outportAddrInfo
  $Params
  $WidthInfoTLC\n
 { \n    real_T *pxc = %<RTMGet(\"ContStates\")>;\n    real_T *dx  =  %<RTMGet(\"dX\")>;\n    $fcnCallDerivativesTLC\n  }
  %%
%endfunction ";

return $Body;
}



###############################################
#  DimsInfo Function for -1 and 1 port widths #
#  or for n and 1 port widths                 #            
###############################################

sub getBodyDimsInfoWidthMdlPortWidth {

($InRow[0], $OutRow[0], $strDynSize, $Inframe[0]) =   @_;

if($Inframe[0] == 1) {
 $DimsInfoBody  = "#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *dimsInfo)
{
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
}
#endif

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
#if defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO)
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port, 
                                          const DimsInfo_T *dimsInfo)
{
 if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
}
#endif\n";


} else {
if($InRow[0] =~ $strDynSize && $OutCol[0] == 1) {
  $inPortDimsInfoWidth = 1;
  $outPortDimsInfoWidth = 1;
  $defaultDimsInfo = "#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { $outPortDimsInfoWidth, 1 };
  bool  frame = (ssGetInputPortFrameData(S, 0) == FRAME_YES) ||
                  (ssGetOutputPortFrameData(S, 0) == FRAME_YES);

  /* Neither the input nor the output ports have been set */

  portDimsInfo.width   = 1;
  portDimsInfo.numDims = frame ? 2 : 1;
  portDimsInfo.dims    = frame ? dims : &portDimsInfo.width;

  if (ssGetInputPortNumDimensions(S, 0) == (-1)) {  
      ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }

  if (ssGetOutputPortNumDimensions(S, 0) == (-1)) {
      ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }
}\n";

} elsif (($InRow[0] > 1  && $OutCol[0] == 1) || $OutDims[0] == "2-D") { 
  $inPortDimsInfoWidth = "INPUT_0_WIDTH";
  $outPortDimsInfoWidth = "OUTPUT_0_WIDTH";
  $defaultDimsInfo = "#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { INPUT_0_WIDTH, 1 };
  bool  frameIn = ssGetInputPortFrameData(S, 0) == FRAME_YES;

  /* Neither the input nor the output ports have been set */

  portDimsInfo.width   = INPUT_0_WIDTH;
  portDimsInfo.numDims = frameIn ? 2 : 1;
  portDimsInfo.dims    = frameIn ? dims : &portDimsInfo.width;
  if (ssGetInputPortNumDimensions(S, 0) == (-1)) {  
   ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }
  portDimsInfo.width   = OUTPUT_0_WIDTH;
  dims[0]              = OUTPUT_0_WIDTH;
 if (ssGetOutputPortNumDimensions(S, 0) == (-1)) {  
  ssSetOutputPortDimensionInfo(S, 0, &portDimsInfo);
 }
  return;
}\n";
}

$DimsInfoBody = "
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                  int              portIndex, 
                                  const DimsInfo_T *dimsInfo)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { OUTPUT_0_WIDTH, 1 };
  bool  frameIn = (ssGetInputPortFrameData(S, 0) == FRAME_YES);

  ssSetInputPortDimensionInfo(S, 0, dimsInfo);

  if (ssGetOutputPortNumDimensions(S, 0) == (-1)) {
      /* the output port has not been set */

      portDimsInfo.width   = $outPortDimsInfoWidth;
      portDimsInfo.numDims = frameIn ? 2 : 1;
      portDimsInfo.dims    = frameIn ? dims : &portDimsInfo.width;
      
      ssSetOutputPortDimensionInfo(S, 0, &portDimsInfo);
  }
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
void mdlSetOutputPortDimensionInfo(SimStruct        *S,         
                                   int_T            portIndex,
                                   const DimsInfo_T *dimsInfo)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { OUTPUT_0_WIDTH, 1 };
  bool  frameOut = (ssGetOutputPortFrameData(S, 0) == FRAME_YES);

  ssSetOutputPortDimensionInfo(S, 0, dimsInfo);

  if (ssGetInputPortNumDimensions(S, 0) == (-1)) {
      /* the input port has not been set */

      portDimsInfo.width   = $inPortDimsInfoWidth;
      portDimsInfo.numDims = frameOut ? 2 : 1;
      portDimsInfo.dims    = frameOut ? dims : &portDimsInfo.width;
      
      ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }
}

\n";
}
return $DimsInfoBody . $defaultDimsInfo;

}

###############################################
#  DimsInfo Function for -1 and N port widths #            
###############################################

sub getBodyMdlPortWidthMinusByN {

$bodyDimsInfoMbyN =
"#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
  {
      ssSetInputPortWidth(S,port,inputPortWidth);
  }
# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
  {
      ssSetOutputPortWidth(S,port,ssGetInputPortWidth(S,0));
  }
#endif";

return $bodyDimsInfoMbyN;
}

###############################################
# Get data type macors
###############################################

sub getDataTypeMacros {
($localDataTypeMacors) = @_; 

my($iDataTypeMacors);
  
if($localDataTypeMacors =~ /real_T$/) {
  $iDataTypeMacors = "SS_DOUBLE";
}
elsif($localDataTypeMacors =~ /real32_T$/) {
  $iDataTypeMacors =  "SS_SINGLE";
}
elsif($localDataTypeMacors =~ /^int8_T$/ 
      || $localDataTypeMacors =~ /^cint8_T$/) {
  $iDataTypeMacors = "SS_INT8";
}
elsif($localDataTypeMacors =~ /^int16_T$/
      || $localDataTypeMacors =~ /^cint16_T$/) {
  $iDataTypeMacors =  "SS_INT16";
}
elsif($localDataTypeMacors =~ /^int32_T$/
      || $localDataTypeMacors =~ /^cint32_T$/) {
  $iDataTypeMacors = "SS_INT32";
}
elsif($localDataTypeMacors =~ /^uint8_T$/
      || $localDataTypeMacors =~ /^cuint8_T$/) {
  $iDataTypeMacors =  "SS_UINT8";
}
elsif($localDataTypeMacors =~ /^uint16_T$/
      || $localDataTypeMacors =~ /^cuint16_T$/) {
  $iDataTypeMacors = "SS_UINT16";
}
elsif($localDataTypeMacors =~ /^uint32_T$/
      || $localDataTypeMacors =~ /^cuint32_T$/) { 
  $iDataTypeMacors = "SS_UINT32";
}
elsif($localDataTypeMacors =~ /^boolean_T$/) {
  $iDataTypeMacors =  "SS_BOOLEAN";
}
elsif($localDataTypeMacors =~ /^fixpt$/) {
  $iDataTypeMacors =  "DataTypeId";
}
return $iDataTypeMacors;
}

sub genStartFcnMethods {
my($startmethods);
$startmethods = "\n\n#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
  }
#endif /*  MDL_START */\n";
return $startmethods;
}

sub genStartFcnMethodsTLC {

local $startmethodsTLC, $ParamsDec, $inportAddrInfo, $outportAddrInfo;

$inportAddrInfo ="";
for($i = 0; $i < $NumberOfInputPorts ; $i++){
  $inportAddrInfo =   $inportAddrInfo . "\n  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)";
}
$outportAddrInfo ="";   
for($i=0; $i < $NumberOfOutputPorts ; $i++){
   $outportAddrInfo =  $outportAddrInfo . "\n  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)";
}   
$n = 1;
if($NumParams){
 for($i=0; $i < $NumParams; $i++){
  $ParamsDec = "$ParamsDec 
  %assign nelements$n = LibBlockParameterSize(P$n)
  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]  
  %if (param_width$n) > 1  
   %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n)
  %else  
   %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
  %endif";
  $n++;
  }
}
$startmethodsTLC ="\n%% Function: Start =============================================================
%%
%function Start(block, system) Output
   /* %<Type> Block: %<Name> */
   $inportAddrInfo $outportAddrInfo
   $ParamsDec\n
%endfunction\n";
return $startmethodsTLC;
}
sub genTerminateFcnMethodsTLC {
my($terminatemethodsTLC);
$terminatemethodsTLC ="\n%% Function: Terminate =============================================================
%%
%function Terminate(block, system) Output
   /* %<Type> Block: %<Name> */

%endfunction\n";
return $terminatemethodsTLC;
}
sub genPortDataTypeMethods {
my($pmethods);
my($inp_methods);
my($ssInpPDT);

  if($NumberOfInputPorts > 0) { 
    $inp_methods = "\n#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int port, DTypeId dType)
{
    ssSetInputPortDataType( S, 0, dType);
}";
    $ssInpPDT = "ssSetInputPortDataType( S, 0, SS_DOUBLE);\n"
  }

$pmethods ="\n#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dType)
{
    ssSetOutputPortDataType(S, 0, dType);
}

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
  $ssInpPDT ssSetOutputPortDataType(S, 0, SS_DOUBLE);
}\n";

return $inp_methods . $pmethods;
}
