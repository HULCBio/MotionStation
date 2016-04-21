function [err,c] = formatai(net,m,Q)
%FORMATAI Format matrix Ai.
%
%  Synopsis
%
%    [err,Ai] = formatai(net,Ai,Q)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code dependant on this function.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

err = [];
c = [];

% [] -> zeros
if any(size(m) == 0)
  c = cell(net.numLayers,net.numLayerDelays);
  for i=1:net.numLayers
    for ts=1:net.numLayerDelays
    c{i,ts} = zeros(net.layers{i}.size,Q);
  end
  end
  return
end

% Check number of rows and columns
if (size(m,1) ~= net.hint.totalLayerSize)
  err = sprintf('Layer states are incorrectly sized for network.\nMatrix must have %g rows.',net.hint.totalLayerSize);
  return
end
if (size(m,2) ~= Q*net.numLayerDelays)
  err = sprintf('Layer states are incorrectly sized for network.\nMatrix must have %g columns.',Q*net.numLayerDelays);
  return
end

% Cell -> Matrix
c = mat2cell(m,net.hint.layerSizes,zeros(1,net.numLayerDelays)+Q);

