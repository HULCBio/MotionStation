function [err,pi] = checkpi(net,pi,Q)
%CHECKPI Check Pi dimensions.
%
%  Synopsis
%
%    [err,pi] = checkpi(net,Pi,Q)
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
if any(size(pi) == 0)
  c = cell(net.numInputs,net.numInputDelays);
  for i=1:net.numInputs
    for ts=1:net.numInputDelays
    c{i,ts} = zeros(net.inputs{i}.size,Q);
  end
  end
  pi = c;
  return
end

% Check cell array dimensions
if (size(pi,1) ~= net.numInputs)
  err = sprintf('Input states are incorrectly sized for network.\nCell array must have %g rows.',net.numInputs);
  return
end
if (size(pi,2) ~= net.numInputDelays)
  err = sprintf('Input states are incorrectly sized for network.\nCell array must have %g columns.',net.numInputDelays);
  return
end

% Check element dimensions
for i=1:net.numInputs
  rows = net.hint.inputSizes(i);
  for j=1:net.numInputDelays
    if (size(pi{i,j},1) ~= rows)
    err = sprintf('Input states are incorrectly sized for network.\nMatrices must all have %g rows.',rows);
    return
  end
    if (size(pi{i,j},2) ~= Q)
    err = sprintf('Input states are not consistently sized.\nMatrices must all have the same numbers of columns.');
    return
  end
  end
end

