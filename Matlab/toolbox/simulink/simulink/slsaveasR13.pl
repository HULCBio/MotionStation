#! /usr/local/bin/perl
###################################
#
# Saves an R14 mdl file into R13sp1 mdl format 

# Copyright 1990-2004 The MathWorks, Inc.
#
# $Revision $


 # Read Input parameters from the data file
 ($dataFile) = @ARGV;
 my(@all_lines);
 open(DAT_IN, "<$dataFile") || die "Unable to open $dataFile";
 @all_lines = <DAT_IN>;
 close(DAT_IN);

 chomp($verString = @all_lines[0]);
 chomp($infilename = @all_lines[1]);
 chomp($outfilename =  @all_lines[2]);
 chomp($tempFileName = @all_lines[3]);
 chomp($newBDParams = @all_lines[4]);
 chomp($newBlocks = @all_lines[5]); 
 chomp($newBlkParams = @all_lines[6]); 
 chomp($refMap = @all_lines[7]); 
 chomp($portPrms = @all_lines[8]);
 chomp($commonBlkParams = @all_lines[9]);

 #Get the Systems parameters to be filtered from the model
 @sysParam = split(/\|/, $newBDParams);

 #Get the Port parameters to be filtered from the model
 @newPortParams = split(/\|/, $portPrms);

 #Get the common block parameters to be filtered from the model
 @newCommonBlockParams = split(/\|/, $commonBlkParams);

 #Get the list of new blocks
 @newBlockList;
 @inputPorts;
 @outputPorts;

 foreach $blk (split(/\|\|/, $newBlocks)) {
     ($b, $ip, $op) = split(/\|/, $blk);
     push @newBlockList, $b;
     push @inputPorts, $ip;
     push @outputPorts, $op;
 }

 # Special case hack for signal specification block
 if ($verString eq "5.0") {
     push @newBlockList, "SignalSpecification";
     push @inputPorts, "1";
     push @outputPorts, "1";
 }

 #Create the new block param hash
 %blkParamHash = ();
 foreach $entry (split(/\|\|/, $newBlkParams)) {
     ($key, $val) = split(/\|/, $entry, 2);
     $blkParamHash{$key} = $val;
 }

 #Create the reference map
 %refHash = ();
 foreach $ref (split(/\|\|/, $refMap)) {
     ($currRef, $oldRef) = split(/\|/, $ref);
     $refHash{$currRef} = $oldRef;
 }

 #Update the model
 UpdateModel($infilename, $outfilename);

# Function UpdateModel =========================================================
# Abstract:
#      Loops over all the lines in the model file and strips out pieces that 
# are new in R14.
#
sub UpdateModel
{
  ($mdl_IN,$mdl_OUT) =  @_;

  open(IN, "<$mdl_IN") || die "Unable to open $mdl_IN";
  open(OUT,">$mdl_OUT") || die "Unable to create $mdl_OUT. Please check the directory permission\n";
  my($blkFlag) = 0;
  my($libFlag) = 0; 
  my($mdlFlag) = 0;
  my($systemFlag) = 0;
  my($blkParamDefaultsFlag) = 0;
  my($stateflowFlag) = 0;
  my($portFlag) = 0;
  
  my($startMultiLineSource) = 0;
  my($goTillSourceBlock) = 0;
  my($ignoreBlock) = 0;
  my($blkType) = "";
  my($done) = 1;
  my($tempStr) = "";
  my($sigSpecDone) = 0;
  my($isSigSpec) = 0;
  my($count) = 0;

  while (<IN>) {  
   #Initialize local variables
   my($dontPrint) = 0;
   my($line) = $_;
   chomp($line); 

   #################################
   # Remove new BD level params    #
   ######################### #######
   if($mdlFlag || $libFlag){
     #Removing model parameters
     foreach $pvString (@sysParam) {
       if ( $line =~ /$pvString/) {
          $dontPrint = 1;
          last;
       }
     }   

     next if $dontPrint;
     
     # Special case hack for ProdHWDeviceType param
     if(/\s*ProdHWDeviceType\s*/) {
	 ($prm, $val) = /(\w+)\s+(.*)/;
	 s/$val/\"Microprocessor\"/g;
     }
   }

   #################################################
   # Removing new blocks from the defaults section #
   #################################################
   if ($blkParamDefaultsFlag) {
       if(/\s*BlockType\s*/../\s*\}\s*$/){  
	   # Get the block type.
	   if (/\s*BlockType\s*/){ 
	       ($dontcare, $blkType) =  /\s*(\w+)\s*(\w+)\s*/;
	   }
	   
	   $dontPrint = SkipBlockParam($line, $blkType);
	   foreach $blk (@newBlockList) {
	       if (index($line, $blk) != -1) {
		   $ignoreBlock = 1;
		   last;
	       }  
	   }
	   next if $ignoreBlock;
	   next if $dontPrint;
       }
       
       if ($ignoreBlock) {
	   print OUT "}\n";
	   $ignoreBlock = 0;
       }
   }

   ############################
   #Removing port parameters  #
   ############################
   if ($portFlag) {
       #Removing port parameters
       ($param, $value) = $line =~ /\s*(\w+)\s*[\"|\{|\[]*.+/;
       foreach $pvString (@newPortParams) {
	   if ( $param =~ /$pvString/) {
	       $dontPrint = 1;
	       last;
	   }
       }   
       next if $dontPrint;
   }

   ########################################################
   #Removing new block params and fixing block references #
   ########################################################
   if ($blkFlag) {
       if(/\s*BlockType\s*/../\s*\}\s*$/){     

	   # Get the block type.
	   if (/\s*BlockType\s*/){ 
	       ($dontcare, $blkType) =  /\s*(\w+)\s*(\w+)\s*/;
	   }

	   # Special case hack for signal specification block
	   if ($verString eq "5.0" && $blkType =~ /SignalSpecification/ && $sigSpecDone == 0) {
	       $isSigSpec = 1;
	       $nameLine = $. + 1;
	       $sigSpecDone = 1;
	       next;
	   }
	   
	   if ($nameLine == $. && $verString eq "5.0" && $blkType =~ /SignalSpecification/) {
	       ($dontcare, $name) = /(\w+)\s+(.*)/; #/\s*(\w+)\s*\"(\w+)\"\s*/;
	       print OUT "\tBlockType\t\"Reference\"\n";
	       print OUT "\tName\t$name\n";
	       print OUT "\tSourceBlock\t\"simulink\/Signal\\nAttributes\/Signal Specification\"\n";
	       print OUT "\tSourceType\t\"Signal Specification\"\n";
	       print OUT "\tPorts\t\[1, 1\]\n";
	       next;
	   }
	   
	   if ($blkType =~ /Reference/ && $done == 1 && $isSigSpec == 0) {
	       $goTillSourceBlock = 1;
	       $done = 0;
	   }

	   if (/\s*SourceBlock\s*/ && $isSigSpec == 0) {
	       ($dontcare, $blkType) =  /\s*(\w+)\s*\"([^\"]+)\"\s*/;
	       $startMultiLineSource = 1;
	       next;
	   }

	   if ($startMultiLineSource == 1 && $isSigSpec == 0) {
	       if ($line =~ /^\s*\"([^\"]+)\"\s*/) {
		   $stuff = $1;
		   $blkType = $blkType . $stuff;
		   next;
	       } else {
		   $goTillSourceBlock = 0;
		   $startMultiLineSource = 0;
		   $done = 1;
	       }
	   }

	   if ($goTillSourceBlock == 1 && $isSigSpec == 0) {
	       $tempStr = $tempStr . "\n" . $line;
	       next;
	   }

	   if ($goTillSourceBlock == 0 && $tempStr ne "" && $isSigSpec == 0) {
	       print OUT $tempStr;
	       $oldRef = $refHash{$blkType};
	       if ($oldRef ne "") {
		   print OUT "\n\tSourceBlock\t\"$oldRef\"\n";
	       } else {
		   print OUT "\n\tSourceBlock\t\"$blkType\"\n";
	       }
	       $tempStr = "";
	   }

	   # Special case hack for signal specification block
	   next if ($isSigSpec == 1 && /\s*Name\s*/);

	   $dontPrint = SkipBlockParam($line, $blkType);
	   next if $dontPrint;
       }
   }

   ######################################### 
   # Create our flags here                 #
   #########################################   
   
   if($line =~ /s*Model {\s*$/../\s*\}\s*$/) { 
    if($line =~ /\sName\s*\"*\"/) { 
      ($var0, $var1) = /(\w+)\s+(.*)/;
	$tempFileName =~ s/(\.\w+)//g; 
	s/$var1/\"$tempFileName\"/g;
    }
       
    #Rename Version String
    if($line =~ /s*Version\s*6.0/){
      s/6.0/$verString/g;
    }
   }
	
   # Create a flag for model parameters
   if($line =~ /s*Model {\s*$/){ 
      $mdlFlag = 1;
   }

   # Create a flag for a library definition  
   if($line =~ /s*Library {\s*$/){ 
     $libFlag = 1;
   }

   # Create a flag for system   
   if($line =~ /s*System {\s*$/../\s*\}\s*$/) { 
     $systemFlag = 1;
     $portFlag = 0;
   }

   # Create a flag for ports   
   if($line =~ /s*Port {\s*$/../\s*\}\s*$/) { 
     $portFlag = 1;
   }

   # Create a flag for a stateflow definition  
   if($line =~ /s*Stateflow {\s*$/){ 
     $stateflowFlag = 1;
     $blkFlag = 0;
     $portFlag = 0;
   }

   # Create a flag for a block parameters defaults definition  
   if($line =~ /s*BlockParameterDefaults {\s*$/){ 
     $blkParamDefaultsFlag = 1;
     $mdlFlag = 0;
     $libFlag = 0;
   }

   # Reset the BlockParamDefaultsFlag to off.
   if($line =~ /s*AnnotationDefaults {\s*$/){ 
     $blkParamDefaultsFlag = 0;
   }

   # Update the flag for a block
   if($line =~ /s*Block {\s*$/){ 
     if($blkParamDefaultsFlag == 0) {
       $blkFlag = 1;
       $systemFlag = 0;
       $portFlag = 0;
       $startMultiLineSource = 0;
       $goTillSourceBlock = 0;
       $done = 1;
       $tempStr = "";
       $sigSpecDone = 0;
       $isSigSpec = 0;
     }
   }
 
   print OUT $_;
  }
  close(IN);
  close(OUT);
}

# Function: SkipBlockParam =====================================================
# Abstract: 
#      Checks to see if the current line has a new block parameter that should
# be skipped.
#
sub SkipBlockParam{

  my($line, $blkType) = @_;
  $retVal = 0;

  ($param, $value) = $line =~ /\s*(\w+)\s*[\"|\{|\[]*.+/;
  
  # Check in the block specific list first
  $val = $blkParamHash{$blkType};
  if ($val ne "") {
      @lst = split(/\|/, $val);
      foreach $entry (@lst) {
	  if ($entry eq $param) {
	      $retVal = 1;
	      last;
	  }
      }
  }
  
  # Check in the common list next
  foreach $item (@newCommonBlockParams) {
      if ($item eq $param) {
	  $retVal = 1;
	  last;
      }
  }

  return $retVal;
}
