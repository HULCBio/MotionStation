function [cq, cr] = zeropadquantized(cq,cr)
%ZEROPADQUANTIZED Zero pad quantized coefficients
%   [CQ, CR] = ZEROPADQUANTIZED(CQ,CR) zero pads quantized coefficients in
%   cell array CQ to match the lengths of the reference coefficients in cell
%   array CR.  This is necessary because the quantized coefficients may have
%   been shortened because of underflow.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:27:58 $

for k=1:length(cr)
  if iscell(cr{k})
    [cq{k}, cr{k}] = zeropadquantized(cq{k}, cr{k});
  else
    % Also make rows
    cq{k} = [cq{k}(:).', zeros(1,length(cr{k}) - length(cq{k}))];
    cr{k} = cr{k}(:).';
  end
end
