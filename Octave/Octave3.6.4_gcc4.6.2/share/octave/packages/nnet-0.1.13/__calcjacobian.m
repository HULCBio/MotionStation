## Copyright (C) 2006 Michel D. Schmid   <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {}@var{Jj} = __calcjacobian (@var{net},@var{Im},@var{Nn},@var{Aa},@var{vE})
## This function calculates the jacobian matrix. It's used inside the
## Levenberg-Marquardt algorithm of the neural network toolbox.
## PLEASE DO NOT USE IT ELSEWEHRE, it proparly will not work!
## @end deftypefn

## Author: Michel D. Schmid


function [Jj] = __calcjacobian(net,Im,Nn,Aa,vE)

  ## comment:
  ## - return value Jj is jacobi matrix
  ##   for this calculation, see "Neural Network Design; Hagan, Demuth & Beale page 12-45"


  ## check range of input arguments
  error(nargchk(5,5,nargin))

  ## get signals from inside the network
  bias  = net.b;

  ## calculate some help matrices
  mInputWeight = net.IW{1} * Im;
  nLayers = net.numLayers;
  for i=2:nLayers
    mLayerWeight{i,1} = net.LW{i,i-1} * Aa{i-1,1};
  endfor

  ## calculate number of columns and rows in jacobi matrix
  ## firstly, number of columns
  a = ones(nLayers+1,1); # +1 is for the input
  a(1) = net.inputs{1}.size;
  for iLayers = 1:nLayers
    a(iLayers+1) = net.layers{iLayers}.size;
  endfor
  nColumnsJacobiMatrix = 0;
  for iLayers = 1:nLayers
    nColumnsJacobiMatrix = (a(iLayers)+1)*a(iLayers+1) + nColumnsJacobiMatrix;
  endfor
  ## secondly, number of rows
  ve = vE{nLayers,1};
  nRowsJacobiMatrix = length(ve(:));


  ## FIRST STEP -----------------------------------------------------
  ## calculate the neuron outputs without the transfer function
  ## - n1_1 = W^1*a_1^0+b^1: the ^x factor defined the xth train data set
  ##   the _x factor defines the layer
  ## **********  this datas should be hold in Nn
  ## **********  should be calculated in "__calcperf"
  ## **********  so Nn{1} means hidden layer
  ## **********  so Nn{2} means second hidden layer or output layer
  ## **********  and so on ...
  ## END FIRST STEP -------------------------------------------------

  ## now we can rerange the signals ... this will be done only for
  ## matrix calculation ...
  [nRowsError nColumnsError] = size(ve);
  errorSize = size(ve(:),1); # this will calculate, if only one row
  # of errors exist... in other words... two rows will be reranged to
  # one row with the same number of elements.
  rerangeIndex = floor([0:(errorSize-1)]/nRowsError)+1;
  nLayers = net.numLayers;

  for i = 1:nLayers
    Nn{i,1} = Nn{i,1}(:,rerangeIndex);
    Aa{i,1} = Aa{i,1}(:,rerangeIndex);
    [nRows nColumns] = size(Nn{i,1});
    bTemp = bias{i,1};
    bias{i,1} = repmat(bTemp,1,nColumns);
    bias{i,1} = bias{i,1}(:,rerangeIndex);
  endfor
  mInputWeight = mInputWeight(:,rerangeIndex);
  for i=2:nLayers
    mLayerWeight{i,1} = mLayerWeight{i,1}(:,rerangeIndex);
  endfor
  Im = Im(:,rerangeIndex);

  ## define how the errors are connected
  ## ATTENTION! this happens in row order...
  numTargets = net.numTargets;
  mIdentity = -eye(numTargets);
  cols = size(mIdentity,2);
  mIdentity = mIdentity(:,rem(0:(cols*nColumnsError-1),cols)+1);
  errorConnect = cell(net.numLayers,1);
  startPos = 0;
  for i=net.numLayers
    targSize = net.layers{i}.size;
    errorConnect{i} = mIdentity(startPos+[1:targSize],:);
    startPos = startPos + targSize;
  endfor

  ## SECOND STEP ----------------------------------------------
  ## define and calculate the derivative matrix dF
  ## - this is "done" by the two first derivative functions
  ##   of the transfer functions
  ##   e.g. __dpureline, __dtansig, __dlogsig and so on ...

  ## calculate the sensitivity matrix tildeS
  ## start at the end layer, this means of course the output layer,
  ## the transfer function is selectable
  
  ## for calculating the last layer
  ## this should happen like following:
  ## tildeSx = -dFx(n_x^x)
  ## use mIdentity to calculate the number of targets correctly
  ## for all other layers, use instead:
  ## tildeSx(-1) = dF1(n_x^(x-1))(W^x)' * tildeSx;

  for iLayers = nLayers:-1:1 # this will count from the last
                             # layer to the first layer ...
    n = Nn{iLayers}; # nLayers holds the value of the last layer...
    ## which transfer function should be used?
    if (iLayers==nLayers)
      switch(net.layers{iLayers}.transferFcn)
        case "radbas"
          tildeSxTemp = __dradbas(n);
        case "purelin"
          tildeSxTemp = __dpurelin(n);
        case "tansig"
          n = tansig(n);
          tildeSxTemp = __dtansig(n);
        case "logsig"
          n = logsig(n);
          tildeSxTemp = __dlogsig(n);
        otherwise	
          error(["transfer function argument: " net.layers{iLayers}.transferFcn  " is not valid!"])
      endswitch
      tildeSx{iLayers,1} = tildeSxTemp .* mIdentity;
      n = bias{nLayers,1};
      switch(net.layers{iLayers}.transferFcn)
        case "radbas"
          tildeSbxTemp = __dradbas(n);
        case "purelin"
          tildeSbxTemp = __dpurelin(n);
        case "tansig"
          n = tansig(n);
          tildeSbxTemp = __dtansig(n);
        case "logsig"
          n = logsig(n);
          tildeSbxTemp = __dlogsig(n);
        otherwise
          error(["transfer function argument: " net.layers{iLayers}.transferFcn  " is not valid!"])
      endswitch
      tildeSbx{iLayers,1} = tildeSbxTemp .* mIdentity;
    endif

    if (iLayers<nLayers)
      dFx = ones(size(n));
      switch(net.layers{iLayers}.transferFcn) ######## new lines ...
        case "radbas"
          nx = radbas(n);
          dFx = __dradbas(nx);
        case "purelin"
	  nx = purelin(n);
	  dFx = __dpurelin(nx);
        case "tansig"         ######## new lines ...
	  nx = tansig(n);
	  dFx = __dtansig(nx);
	case "logsig"    ######## new lines ...
          nx = logsig(n);  ######## new lines ...
	  dFx = __dlogsig(nx); ######## new lines ...
	otherwise     ######## new lines ...
	  error(["transfer function argument: " net.layers{iLayers}.transferFcn  " is not valid!"])######## new lines ...
       endswitch ############# new lines ....
	  LWtranspose = net.LW{iLayers+1,iLayers};
      if iLayers<(nLayers-1)
        mIdentity = -ones(net.layers{iLayers}.size,size(mIdentity,2));
      endif

      mTest = tildeSx{iLayers+1,1};
      LWtranspose = LWtranspose' * mTest;
      tildeSx{iLayers,1} = dFx .* LWtranspose;
      tildeSxTemp = dFx .* LWtranspose;
      tildeSbx{iLayers,1} = ones(size(nx)).*tildeSxTemp;
    endif

  endfor #  if iLayers = nLayers:-1:1
  ## END SECOND STEP -------------------------------------------------

  ## THIRD STEP ------------------------------------------------------
  ## some problems occur if we have more than only one target... so how
  ## does the jacobi matrix looks like?

  ## each target will cause an extra row in the jacobi matrix, for
  ## each training set..  this means, 2 targets --> double of rows in the
  ## jacobi matrix ... 3 targets --> three times the number of rows like
  ## with one target and so on.

  ## now calculate jacobi matrix
  ## to do this, define first the transposed of it
  ## this makes it easier to calculate on the "batch" way, means all inputs
  ## at the same time...
  ## and it makes it easier to use the matrix calculation way..

  JjTrans = zeros(nRowsJacobiMatrix,nColumnsJacobiMatrix)'; # transposed jacobi matrix

  ## Weight Gradients
  for i=1:net.numLayers
    if i==1
      newInputs = Im;
      newTemps =  tildeSx{i,1};
      gIW{i,1} = copyRows(newTemps,net.inputs{i}.size) .* copyRowsInt(newInputs,net.layers{i}.size);
    endif
    if i>1
      Ad = cell2mat(Aa(i-1,1)');
      newInputs = Ad;
      newTemps = tildeSx{i,1};
      gLW{i,1} = copyRows(newTemps,net.layers{i-1}.size) .* copyRowsInt(newInputs,net.layers{i}.size);
    endif
  endfor

  for i=1:net.numLayers
    [nRows, nColumns] = size(Im);
    if (i==1)
      nWeightElements = a(i)*a(i+1); # n inputs * n hidden neurons
      JjTrans(1:nWeightElements,:) =  gIW{i}(1:nWeightElements,:);
      nWeightBias = a(i+1);
      start = nWeightElements;
      JjTrans(start+1:start+nWeightBias,:) = tildeSbx{i,1};
      start = start+nWeightBias;
    endif
    if (i>1)
      nLayerElements = a(i)*a(i+1); # n hidden neurons * n output neurons
      JjTrans(start+1:start+nLayerElements,:)=gLW{i}(1:nLayerElements,:);
      start = start +  nLayerElements;
      nLayerBias = a(i+1);
      JjTrans(start+1:start+nLayerBias,:) = tildeSbx{i,1};
      start = start + nLayerBias;
    endif
  endfor
  Jj = JjTrans';
  ## END THIRD STEP -------------------------------------------------


#=======================================================
#
# additional functions
#
#=======================================================

  function k = copyRows(k,m)
    # make copies of the ROWS of Aa matrix

    mRows = size(k,1);
    k = k(rem(0:(mRows*m-1),mRows)+1,:);
  endfunction

# -------------------------------------------------------

  function k = copyRowsInt(k,m)
    # make copies of the ROWS of matrix with elements INTERLEAVED

    mRows = size(k,1);
    k = k(floor([0:(mRows*m-1)]/m)+1,:);
  endfunction

# =====================================================================
#
# END additional functions
#
# =====================================================================

endfunction
