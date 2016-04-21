## Copyright (C) 2005 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
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
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{net}} = newff (@var{Pr},@var{ss},@var{trf},@var{btf},@var{blf},@var{pf})
## @code{newff} create a feed-forward backpropagation network
##
## @example
## Pr - R x 2 matrix of min and max values for R input elements
## Ss - 1 x Ni row vector with size of ith layer, for N layers
## trf - 1 x Ni list with transfer function of ith layer,
##       default = "tansig"
## btf - Batch network training function,
##       default = "trainlm"
## blf - Batch weight/bias learning function,
##       default = "learngdm"
## pf  - Performance function,
##       default = "mse".
## @end example
##
## @example
## EXAMPLE 1
## Pr = [0.1 0.8; 0.1 0.75; 0.01 0.8];
##      it's a 3 x 2 matrix, this means 3 input neurons
##
## net = newff(Pr, [4 1], @{"tansig","purelin"@}, "trainlm", "learngdm", "mse");
## @end example
##
## @end deftypefn

## @seealso{sim, init, train}

## Author: Michel D. Schmid

function net = newff(Pr,ss,transFunc,trainFunc,notUsed,performFunc)

  ## initial descriptipn
  ##  newff(Pr,ss,transfunc,trainFunc,notUsed,performFunc)
  ##  * Pr is a nx2 matrix with min and max values of standardized inputs
  ##    Pr means: p-range
  ##  * ss is a row vector, the first element describes the number
  ##    of hidden neurons, the second element describes the number
  ##    of output neurons
  ##  * transFunc is a cell array of transfer function, standard is "tansig"
  ##  * trainFunc is the training algorithm
  ##  * notUsed exist only because we have only one train algorithm which doesn't
  ##    need a weight learning function
  ##  * performFunc is written for the performance function, standard is "mse"

  ## check range of input arguments
  error(nargchk(2,6,nargin))

  ## get number of layers (without input layer)
  nLayers = length(ss);

  ## set defaults
  if (nargin <3)
    # the number of transfer functions depends on the number of
    # hidden layers, so we have to create a loop here 30.09.09 (dd.mm.yy)
	for i=1:nLayers
	  if (i==nLayers)
	    transFunc{i,1} = "purelin";
	  else
        transFunc{i,1}= "tansig";
      endif
    endfor
  endif
  if (nargin <4)
    trainFunc = "trainlm";
  endif
  if (nargin <5)
    notUsed = "noSense";
  endif
  if (nargin==5)
    ## it doesn't matter what nargin 5 is ...!
    ## it won't be used ... it's only for matlab compatibility
    notUsed = "noSense"
  endif
  if (nargin <6)
    performFunc = "mse";
  endif

  ## check input args
  checkInputArgs(Pr,ss);

  ## Standard architecture of neural network
  net = __newnetwork(1,nLayers,1,"newff");
  ## description:
  ##	first argument: number of inputs, nothing else allowed till now
  ## it's not the same like the number of neurons in this input
  ## second argument: number of layers, including output layer
  ## third argument: number of outputs, nothing else allowed till now
  ## it's not the same like the number of neurons in this output

  ## set inputs with limit of only ONE input
  net.inputs{1}.range = Pr;
  [nRows, nColumns] = size(Pr);
  net.inputs{1}.size = nRows;

  ## set size of IW
  net.IW{1,1} = zeros(1,nRows);
  ## set more needed empty cells
  for iLayers = 2:nLayers
    net.IW{iLayers,1} = [];
    #  net.IW{2:nLayers,1} = [];    # old code
  endfor
  ## set number of bias, one per layer
  for iBiases = 1:nLayers
    net.b{iBiases,1} = 0;
  endfor

  ## set rest of layers

  ## set size of LayerWeights LW
  ## the numbers of rows and columns depends on the
  ## number of hidden neurons and output neurons...
  ## 2 hidden neurons match 2 columns ...
  ## 2 output neurons match 2 rows ...
  for i=2:nLayers
    net.LW{i,i-1} = zeros(ss(i),ss(i-1));
  endfor
  for iLayers = 1:nLayers
    net.layers{iLayers}.size = ss(iLayers);
    net.layers{iLayers}.transferFcn = transFunc{iLayers};
  endfor

  ## define everything with "targets"
  net.numTargets = ss(end);
  net.targets = cell(1,nLayers);
  for i=1:nLayers
    if (i==nLayers)
      net.targets{i}.size = ss(end);
      ## next row of code is only for MATLAB(TM) compatibility
      ## I never used this the last 4 years ...
      net.targets{i}.userdata = "Put your custom informations here!";
    else
      net.targets{i} = [];
    endif
  endfor

  ## Performance
  net.performFcn = performFunc;

  ## Adaption
  for i=1:nLayers
#    net.biases{i}.learnFcn = blf;
#    net.layerWeights{i,:}.learnFcn = blf;
    net.biases{i}.size = ss(i);
  endfor

  ## Training
  net.trainFcn = trainFunc; # actually, only trainlm will exist
  net = setTrainParam(net);
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

    ## check if ss has correct format, must be 1xR row vector
    if (size(ss,1)!=1)
      error("Layer sizes is not a row vector.")
    endif
    if (size(ss,2)<2)
      error("There must be at least one hidden layer and one output layer!")
    endif
    for k=1:length(ss)
      sk = ss(k);
      if !isreal(sk) | any(sk<1) | any(round(sk)!=sk)
        error("Layer sizes is not a row vector of positive integers.")
      endif
    endfor

  endfunction
# ======================================================
#
# additional set functions...
#
# ======================================================
  function net = setTrainParam(net)

    trainFunc = net.trainFcn;
    switch(trainFunc)

    case "trainlm"
      net.trainParam.epochs = 100;
      net.trainParam.goal = 0;
      net.trainParam.max_fail = 5;
      net.trainParam.mem_reduc = 1;
      net.trainParam.min_grad = 1.0000e-010;
      net.trainParam.mu = 0.0010;
      net.trainParam.mu_dec = 0.1;
      net.trainParam.mu_inc = 10;
      net.trainParam.mu_max = 1.0000e+010;
      net.trainParam.show = 50;
      net.trainParam.time = Inf;
    otherwise
      error("newff:setTrainParam: this train algorithm isn't available till now!")
    endswitch

  endfunction
# ========================================================  


endfunction

%!shared
%! disp("testing newff")

# if input range Pr has only one column
%!test
%! Pr = [1;2];
%! fail("newff(Pr,[1 1],{'tansig','purelin'},'trainlm','unused','mse')","Input ranges must be a two column matrix!")

# if input range Pr has two columns
%!test
%! Pr = [1 2 ; 4  6];
%! assert(__checknetstruct(newff(Pr,[1 1],{'tansig','purelin'},'trainlm','unused','mse')))
  ## __checknetstruct returns TRUE is input arg is a network structure ...

# if input range Pr has three columns
%!test
%! Pr = [1 2 3; 4 5 6];
%! fail("newff(Pr,[1 1],{'tansig','purelin'},'trainlm','unused','mse')","Input ranges must be a two column matrix!")

# if input range has in the second col greater values as in the first col ...
%!test
%! Pr = [5 3; 4 5];
%! fail("newff(Pr,[1 1],{'tansig','purelin'},'trainlm','unused','mse')",\
%!  "Input ranges has values in the second column larger as in the same row of the first column.")

# check if ss has correct format
%!test
%! Pr = [1 2 ; 4 6];
%! fail("newff(Pr,[1 1; 2 3],{'tansig','purelin'},'trainlm','unused','mse')",\
%!  "Layer sizes is not a row vector.")

# check if ss has correct format
%!test
%! Pr = [1 2 ; 4 6];
%! assert(__checknetstruct(newff(Pr,[ 2 3],{'tansig','purelin'},'trainlm','unused','mse')))

# check if ss has correct format
%!test
%! Pr = [1 2 ; 4 6];
%! fail("newff(Pr,[1],{'tansig','purelin'},'trainlm','unused','mse')",\
%!  "There must be at least one hidden layer and one output layer!")

# check if ss has correct format
%!test
%! Pr = [1 2 ; 4 6];
%! fail("newff(Pr,[-1 1],{'tansig','purelin'},'trainlm','unused','mse')",\
%!  "Layer sizes is not a row vector of positive integers.")
