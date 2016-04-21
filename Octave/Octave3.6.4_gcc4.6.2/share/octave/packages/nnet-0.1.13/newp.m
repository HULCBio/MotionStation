## Copyright (C) 2007 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{net}} = newp (@var{Pr},@var{ss},@var{transFunc},@var{learnFunc})
## @code{newp} create a perceptron
##
## @example
## PLEASE DON'T USE THIS FUNCTIONS, IT'S STILL NOT FINISHED!
## =========================================================
## @end example
## @example
## Pr - R x 2 matrix of min and max values for R input elements
## ss - a scalar value with the number of neurons
## transFunc - a string with the transfer function
##       default = "hardlim"
## learnFunc - a string with the learning function
##       default = "learnp"
## @end example
##
##
## @end deftypefn

## @seealso{}

## Author: Michel D. Schmid

function net = newp(Pr,ss,transFunc,learnFunc)

  ## initial descriptipn
  ##  newp(Pr,ss,transFunc,learnFunc)
  ##  * Pr is a nx2 matrix with min and max values of standardized inputs
  ##    Pr means: p-range
  ##  * ss is a scalar value which describes the number of neurons
  ##    of output neurons
  ##  * transFunc is the transfer function, standard is "hardlim"
  ##  * learnFunc is the learning function, standard is "learnp"

  ## check range of input arguments
  error(nargchk(1,4,nargin))

  ## set defaults
  if (nargin <2)
    ss = 1; # means one neuron
  endif
  if (nargin <3)
    transFunc = "hardlim";
  endif
  if (nargin <4)
    learnFunc = "learnp";
  endif

  ## check input args
  checkInputArgs(Pr,ss);

#   ## get number of layers (without input layer)
#   nLayers = length(ss);

  ## Standard architecture of neural network
  net = __newnetwork(1,1,1,"newp");
  ## description:
  ##	first argument: number of inputs, nothing else allowed till now
  ## it's not the same like the number of neurons in this input
  ## second argument: number of layers, including output layer
  ## third argument: number of outputs, nothing else allowed till now
  ## it's not the same like the number of neurons in this output
  ## fourth argument: network type


  ## set inputs with limit of only ONE input
  net.inputs{1}.range = Pr;
  [nRows, nColumns] = size(Pr);
  net.inputs{1}.size = nRows;

  ## set size of IW
  net.IW{1,1} = zeros(1,nRows);
  ## set number of bias, one per layer
  net.b{iBiases,1} = 0;

  ## define everything with "layers"
  net.numLayers = ss(end);
  net.layers = cell(1,1);
  net.layers{1}.size = ss(end);
  net.layers{1}.transFcn = transFunc;
  ## next row of code is only for MATLAB(TM) compatibility
  ## I never used this the last 4 years ...
  net.targets{i}.userdata = "Put your custom informations here!";

  ## performance function
  net.performFnc = "mae";

  ## learning
  net.biases{1}.learnFcn = learnFunc;
  net.inputWeights{1,1}.learnFcn = learnFunc;

  ## adaption
  net.adaptFcn = "trains";

  ## Training
  net.trainFcn = "trainc";

  ## Initialization
  net = __init(net);

# ======================================================
#
# additional check functions...
#
# ======================================================
  function checkInputArgs(Pr,ss)
    
    ## check if Pr has correct format
    if !isreal(Pr) | (size(Pr,2)!=2)
      error("Input ranges must be a two column matrix!")
    endif
    if any(Pr(:,1) > Pr(:,2)) # check if numbers in the second column are larger as in the first one
      error("Input ranges has values in the second column larger as in the same row of the first column.")
    endif

    ## check if ss has correct format, must be a scalar value
    if ( (size(ss,1)!=1) || (size(ss,2)!=1))
      error("Layer sizes is not a scalar value.")
    endif

  endfunction

# ========================================================  


endfunction