## Copyright (C) 2005 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} saveMLPStruct (@var{net},@var{strFileName})
## @code{saveStruct} saves a neural network structure to *.txt files
## @end deftypefn

## Author: Michel D. Schmid

function saveMLPStruct(net,strFileName)

  ## the variable net holds the neural network structure..
  # check if "net" is a structure type
  if !__checknetstruct(net)
    error("Structure doesn't seem to be a neural network")
  endif

  # open the first level file
  fid1 = fopen(strFileName,"w+t","ieee-le");

  if (fid1 < 0)
    error ("Can not open %s", strFileName);
  endif

  ## print header
#   try            ## wird nicht mehr benötigt..
    __printMLPHeader(fid1);
#   catch
#     ## Add saveMLPStructure directory to the path and try again
#     addpath ([fileparts(mfilename()),"/saveMLPStructure"]);
#     __printMLPHeader(fid1);
#   end_try_catch
  
  ## check for field "networkType"
  __printNetworkType(fid1,net);

  ## check for field "numInputs"
  __printNumInputs(fid1,net);

  ## check for field "numLayers"
  __printNumLayers(fid1,net)

  ## check for field "biasConnect"
  __printBiasConnect(fid1,net)

  ## check for field "inputConnect"
  __printInputConnect(fid1,net)

  ## check for field "layerConnect"
  __printLayerConnect(fid1,net)

  ## check for field "outputConnect"
  __printOutputConnect(fid1,net)

  ## check for field "targetConnect"
  __printTargetConnect(fid1,net)

  ## print one empty line
  fprintf(fid1,"\n");

  ## check for numOutputs
  __printNumOutputs(fid1,net);

  ## check for numTargets
  __printNumTargets(fid1,net);

  ## check for numInputDelays
  __printNumInputDelays(fid1,net);

  ## check for numLayerDelays
  __printNumLayerDelays(fid1,net);

  ## print one empty line
  fprintf(fid1,"\n");

  ## print subobject structures:
  fprintf(fid1,"  subobject structures:\n");

  ## print one empty line
  fprintf(fid1,"\n");

  ## print inputs
  __printInputs(fid1,net);

  ## print layers
  __printLayers(fid1,net);

  ## print outputs
  __printOutputs(fid1,net);

  ## print targets
  __printTargets(fid1,net);

  ## print biases
  __printBiases(fid1,net);

  ## print inputweights
  __printInputWeights(fid1,net);

  ## print layerweights
  __printLayerWeights(fid1,net);

  ## print one empty line
  fprintf(fid1,"\n");

  ## print subobject structures:
  fprintf(fid1,"  functions:\n");

  ## print one empty line
  fprintf(fid1,"\n");

  ## print adaptFcn
  __printAdaptFcn(fid1,net);

  ## print initFcn
  __printInitFcn(fid1,net);

  ## print performFcn
  __printPerformFcn(fid1,net);

  ## print performFcn
  __printTrainFcn(fid1,net);

  ## print one empty line
  fprintf(fid1,"\n");

  ## print subobject structures:
  fprintf(fid1,"  parameters:\n");

  ## print one empty line
  fprintf(fid1,"\n");

  ## print adaptParam
  __printAdaptParam(fid1,net);

  ## print initParam
  __printInitParam(fid1,net);

  ## print performParam
  __printPerformParam(fid1,net);

  ## print trainParam
  __printTrainParam(fid1,net);

  ## print one empty line
  fprintf(fid1,"\n");

  ## print subobject structures:
  fprintf(fid1,"  weight & bias values:\n");

  ## print one empty line
  fprintf(fid1,"\n");

  ## print IW
  __printIW(fid1,net);

  ## print LW
  __printLW(fid1,net);

  ## print b
  __printB(fid1,net);

  ## print one empty line
  fprintf(fid1,"\n");

  ## print subobject structures:
  fprintf(fid1,"  other:\n");


  fclose(fid1);

endfunction
