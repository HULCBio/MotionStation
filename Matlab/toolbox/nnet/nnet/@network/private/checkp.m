function [err] = checkp(net,p,Q,TS)
%CHECKP Check P dimensions.
%
%  Synopsis
%
%    [err] = checkp(net,P,Q,TS)
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

% Check dimensions
if (size(p,1) ~= net.numInputs)
  err = sprintf('Inputs are incorrect size for network.\nCell array must have %g rows.',net.numInputs);
  return
end
if (size(p,2) ~= TS)
  err = sprintf('Inputs are incorrectly sized for network.\nCell array must have %g columns.',TS);
  return
end

% Check element dimensions
for i=1:net.numInputs
  rows = net.hint.inputSizes(i);
  for j=1:TS
    if (size(p{i,j},1) ~= rows)
    err = sprintf('Inputs are incorrectly sized for network.\nMatrices must all have %g rows.',rows);
    return
  end
    if (size(p{i,j},2) ~= Q)
    err = sprintf('Inputs are not consistently sized.\nMatrices must all have the same numbers of columns.');
    return
  end
  end
end

