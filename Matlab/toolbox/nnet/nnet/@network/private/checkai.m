function [err,ai] = checkai(net,ai,Q)
%CHECKAI Check Ai dimensions.
%
%  Synopsis
%
%    [err,Ai] = checkpi(net,Ai,Q)
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

% [] -> zeros
if any(size(ai) == 0)
  c = cell(net.numLayers,net.numLayerDelays);
  for i=1:net.numLayers
    for ts=1:net.numLayerDelays
    c{i,ts} = zeros(net.layers{i}.size,Q);
  end
  end
  ai = c;
  return
end

% Check cell array dimensions
if (size(ai,1) ~= net.numLayers)
  err = sprintf('Layer states are incorrectly sized for network.\nCell array must have %g rows.',net.numLayers);
  return
end
if (size(ai,2) ~= net.numLayerDelays)
  err = sprintf('Layer states are incorrectly sized for network.\nCell array must have %g columns.',net.hint.layerDelays);
  return
end

% Check element dimensions
for i=1:net.numLayers
  rows = net.hint.layerSizes(i);
  for j=1:net.numLayerDelays
    if (size(ai{i,j},1) ~= rows)
    err = sprintf('Layer states are incorrectly sized for network.\nMatrices must all have %g rows.',rows);
    return
  end
    if (size(ai{i,j},2) ~= Q)
    err = sprintf('Layer states are not consistently sized.\nMatrices must all have the same numbers of columns.');
    return
  end
  end
end
