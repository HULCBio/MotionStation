function [err,c] = formatp(net,m,Q)
%FORMATP Format matrix  P.
%
%  Synopsis
%
%    [err,P] = formatp(net,P,Q)
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

% Check number of rows
if (size(m,1) ~= net.hint.totalInputSize)
  err = sprintf('Inputs are incorrectly sized for network.\nMatrix must have %g rows.',net.hint.totalInputSize);
  return
end
if (size(m,2) ~= Q)
  err = sprintf('Inputs are incorrectly sized.\nMatrix must have %g columns.',Q);
  return
end

% Cell -> Matrix
c = mat2cell(m,net.hint.inputSizes);
