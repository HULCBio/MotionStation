function [err,c] = formatpi(net,m,Q)
%FORMATPI Format matrix Pi.
%
%  Synopsis
%
%    [err,Pi] = formatpi(net,Pi,Q)
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
  c = cell(net.numInputs,net.numInputDelays);
  for i=1:net.numInputs
    for ts=1:net.numInputDelays
    c{i,ts} = zeros(net.inputs{i}.size,Q);
  end
  end
  return
end

% Check number of rows and columns
if (size(m,1) ~= net.hint.totalInputSize)
  err = sprintf('Input states are incorrectly sized for network.\nMatrix must have %g rows.',net.hint.totalInputSize);
  return
end
if (size(m,2) ~= Q*net.numInputDelays)
  err = sprintf('Input states are incorrectly sized for network.\nMatrix must have %g columns.',Q*net.numInputDelays);
  return
end

% Cell -> Matrix
c = mat2cell(m,net.hint.inputSizes,zeros(1,net.numInputDelays)+Q);
