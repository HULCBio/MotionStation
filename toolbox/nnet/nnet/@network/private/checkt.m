function [err,t] = checkt(net,t,Q,TS)
%CHECKT Check T dimensions.
%
%  Synopsis
%
%    [err,T] = checkp(net,T,Q,TS)
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
if any(size(t) == 0)
  c = cell(net.numTargets,TS);
  for i=1:net.numTargets
    for ts=1:TS
    c{i,ts} = zeros(net.hint.targetSizes(i),Q);
  end
  end
  t = c;
  return
end

% Check cell array dimensions
if (size(t,1) ~= net.numTargets)
  err = sprintf('Targets are incorrectly sized for network.\nCell array must have %g rows.',net.numTargets);
  return
end
if (size(t,2) ~= TS)
  err = sprintf('Targets are incorrectly sized for network.\nCell array must have %g columns.',TS);
  return
end

% Check element dimensions
for i=1:net.numTargets
  rows = net.hint.targetSizes(i);
  for j=1:TS
    if (size(t{i,j},1) ~= rows)
    err = sprintf('Targets are incorrectly sized for network.\nMatrices must all have %g rows.',rows);
    return
  end
    if (size(t{i,j},2) ~= Q)
    err = sprintf('Targets are not consistently sized.\nMatrices must all have the same numbers of columns.');
    return
  end
  end
end

