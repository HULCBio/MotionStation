## Copyright (C) 2006 Michel D. Schmid    <email: michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {}[@var{perf}, @var{Ee}, @var{Aa}, @var{Nn}] = __calcperf (@var{net},@var{xx},@var{Im},@var{Tt})
## @code{__calcperf} calculates the performance of a multi-layer neural network.
## PLEASE DON'T USE IT ELSEWHERE, it proparly won't work.
## @end deftypefn

## Author: Michel D. Schmid


function [perf,Ee,Aa,Nn] = __calcperf(net,xx,Im,Tt)

  ## comment:
  ## perf, net performance.. from input to output through the hidden layers
  ## Aa, output values of the hidden and last layer (output layer)
  ## is used for NEWFF network types

  ## calculate bias terms
  ## must have the same number of columns like the input matrix Im
  [nRows, nColumns] = size(Im);
  Btemp = cell(net.numLayers,1); # Btemp: bias matrix
  ones1xQ = ones(1,nColumns);
  for i= 1:net.numLayers
    Btemp{i} = net.b{i}(:,ones1xQ);
  endfor

  ## shortcuts
  IWtemp = cell(net.numLayers,net.numInputs,1);# IW: input weights ...
  LWtemp = cell(net.numLayers,net.numLayers,1);# LW: layer weights ...
  Aa = cell(net.numLayers,1);# Outputs hidden and output layer
  Nn = cell(net.numLayers,1);# outputs before the transfer function
  IW = net.IW; # input weights
  LW = net.LW; # layer weights

  ## calculate the whole network till outputs are reached...
  for iLayers = 1:net.numLayers

    ## calculate first input weights to weighted inputs..
    ## this can be done with matrix calculation...
    ## called "dotprod"
    ## to do this, there must be a special matrix ...
    ## e.g.  IW = [1 2 3 4 5; 6 7 8 9 10] * [ 1 2 3; 4 5 6; 7 8 9; 10 11 12; 1 2 3];
    if (iLayers==1)
      IWtemp{iLayers,1} = IW{iLayers,1} * Im;
      onlyTempVar = [IWtemp(iLayers,1) Btemp(iLayers)];
    else
      IWtemp{iLayers,1} = [];
    endif

    ## now calculate layer weights to weighted layer outputs
    if (iLayers>1)
      Ad = Aa{iLayers-1,1};
      LWtemp{iLayers,1} = LW{iLayers,iLayers-1} * Ad;
      onlyTempVar = [LWtemp(iLayers,1) Btemp(iLayers)];
    else
      LWtemp{iLayers,1} = [];
    endif

    Nn{iLayers,1} = onlyTempVar{1};
    for k=2:length(onlyTempVar)
      Nn{iLayers,1} = Nn{iLayers,1} + onlyTempVar{k};
    endfor

    ## now calculate with the transfer functions the layer output
    switch net.layers{iLayers}.transferFcn
    case "purelin"
      Aa{iLayers,1} = purelin(Nn{iLayers,1});
    case "tansig"
      Aa{iLayers,1} = tansig(Nn{iLayers,1});
    case "logsig"
      Aa{iLayers,1} = logsig(Nn{iLayers,1});
    otherwise
      error(["Transfer function: " net.layers{iLayers}.transferFcn " doesn't exist!"])
    endswitch

  endfor  # iLayers = 1:net.numLayers

  ## now calc network error
  Ee = cell(net.numLayers,1);

  for i=net.numLayers
    Ee{i,1} = Tt{i,1} - Aa{i,1};# Tt: target
    # Ee will be the error vector cell array
  endfor

  ## now calc network performance
  switch(net.performFcn)
  case "mse"
    perf = __mse(Ee);
  otherwise
    error("for performance functions, only mse is currently valid!")
  endswitch

endfunction
