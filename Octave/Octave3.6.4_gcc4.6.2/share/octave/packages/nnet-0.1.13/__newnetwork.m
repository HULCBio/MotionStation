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
## @deftypefn {Function File} {}{@var{net}} = __newnetwork(@var{numInputs},@var{numLayers},@var{numOutputs},@var{networkType})
## @code{__newnetwork} create a custom 'zero'-network
##
##
## @example
## net = __newnetwork(numInputs,numLayers,numOutputs,networkType)
##
## numInputs : number of input vectors, actually only 1 allowed
## numLayers : number of layers
## numOutputs: number of output vectors, actually only 1 allowed
## networkType: e.g. feed-forward-network "newff"
## @end example
##
## @example
## net = __newnetwork(1,2,1,"newff")
##       1 input layer, two hidden layers, one output layer
##       and the network type
## @end example
##
## @noindent
## @end deftypefn

## Author: Michel D. Schmid

function net = __newnetwork(numInputs,numLayers,numOutputs,networkType)

  ## check range of input arguments
  error(nargchk(4,4,nargin))

  ## check input args
  if ( !isposint(numInputs) )
    error("network: at least 1 input must be defined! ")
    # this can't happen actually, only one is allowed and this
    # one is hard coded
  elseif ( !isposint(numLayers) )
    error("network: at least 1 hidden- and one output layer must be defined! ")
  endif
  ## second check for numLayers... must be at least "2" for the
  ## newff, this means at least 1 hidden and 1 output layer
  if (strcmp(networkType,"newff")  && (numLayers<2))
    error("network: not enough layers are defined! ")
  endif

  ## define network type
  net.networkType = networkType;

  ## ZERO NETWORK
  net.numInputs = 0;
  net.numLayers = 0;
  net.numInputDelays = 0;
  net.numLayerDelays = 0;
  # the next five parameters aren't used till now, they are used
  # only for matlab nnet type compatibility ==> saveMLPStruct
  net.biasConnect = [];   # not used parameter till now
  net.inputConnect = [];  # not used parameter till now
  net.layerConnect = [];  # not used parameter till now
  net.outputConnect = []; # not used parameter till now
  net.targetConnect = []; # not used parameter till now
  net.numOutputs = 0;
  net.numTargets = 0;
  net.inputs = cell(0,1);
  net.layers = cell(0,1);
  net.biases = cell(0,1);
  net.inputWeights = cell(0,0);
  net.layerWeights = cell(0,0);
  net.outputs = cell(1,0);
  net.targets = cell(1,0);
  net.performFcn = "";
  net.performParam = [];
  net.trainFcn = "";
  net.trainParam = [];
  net.IW = {};
  net.LW = {};
  net.b = cell(0,1);
  net.userdata.note = "Put your custom network information here.";


  ## ARCHITECTURE
  
  ## define everything with "inputs"
  net.numInputs = numInputs;
  ## actually, it's only possible to have "one" input vector
  net.inputs{1,1}.range = [0 0];
  net.inputs{1,1}.size = 0;
  net.inputs{1,1}.userdata = "Put your custom informations here!";
  
  ## define everything with "layers"
  net.numLayers = numLayers;
  net = newLayers(net,numLayers);

  ## define unused variables, must be defined for saveMLPStruct
  net.biasConnect = [0; 0];
  net.inputConnect = [0; 0];
  net.layerConnect = [0 0; 0 0];
  net.outputConnect = [0 0];
  net.targetConnect = [0 0];
  net.numInputDelays = 0;
  net.numLayerDelays = 0;

  ## define everything with "outputs"
  net.numOutputs = numOutputs;
  net.outputs = cell(1,numLayers);
  for i=1:numLayers
    if (i==numLayers)
      net.outputs{i}.size = 1; # nothing else allowed till now
      net.outputs{i}.userdata = "Put your custom informations here!";
    else
      net.outputs{i} = [];
    endif
  endfor

  ## define everything with "biases"
  net = newBiases(net,numLayers);



#=====================================================
#
# Additional ARCHITECTURE Functions
#
#=====================================================
  function net = newLayers(net,numLayers)

    ## check range of input arguments
    error(nargchk(2,2,nargin))

    ## check type of arguments
    if ( !isscalar(numLayers) | !isposint(numLayers) )
      error("second argument must be a positive integer scalar value!")
    endif
    if ( !__checknetstruct(net) )
      error("first argument must be a network structure!")
    endif

    for iRuns=1:numLayers
      net.layers{iRuns,1}.dimension = 0;
      net.layers{iRuns,1}.netInputFcn = "";
      net.layers{iRuns,1}.size = 0;
### TODO: test with newff      net.layers{iRuns,1}.transferFcn = "tansig";
      net.layers{iRuns,1}.transferFcn = "";
      net.layers{iRuns,1}.userdata = "Put your custom informations here!";
    endfor

  endfunction

#-----------------------------------------------------

  function net = newBiases(net,numLayers)

    ## check range of input arguments
    error(nargchk(2,2,nargin))

    ## check type of arguments
    if ( !isscalar(numLayers) | !isposint(numLayers) )
      error("second argument must be a positive integer scalar value!")
    endif
    if ( !isstruct(net) )
      error("first argument must be a network structure!")
    endif

    for iRuns=1:numLayers
      net.biases{iRuns,1}.learn = 1;
      net.biases{iRuns,1}.learnFcn = "";
      net.biases{iRuns,1}.learnParam = "undefined...";
      net.biases{iRuns,1}.size = 0;
      net.biases{iRuns,1}.userdata = "Put your custom informations here!";
    endfor

  endfunction

# ================================================================
#
#             END Additional ARCHITECTURE Functions
#
# ================================================================

endfunction