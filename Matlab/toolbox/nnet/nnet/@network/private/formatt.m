function [err,c] = formatt(net,m,Q,TS)
%FORMATT Format matrix T.
%
%  Synopsis
%
%    [err,T] = formatt(net,T,Q)
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
  c = cell(net.numTargets,TS);
  for i=1:net.numTargets
    for ts=1:TS
    c{i,ts} = zeros(net.hint.targetSizes(i),Q);
  end
  end
  return
end

% Check number of rows
if (size(m,1) ~= net.hint.totalTargetSize)
  err = sprintf('Targets are incorrectly sized for network.\nMatrix must have %g rows.',net.hint.totalTargetSize);
  return
end
if (size(m,2) ~= Q)
  err = sprintf('Targets are incorrectly sized for network.\nMatrix must have %g columns.',Q);
  return
end

% Cell -> Matrix
c = mat2cell(m,net.hint.targetSizes);

