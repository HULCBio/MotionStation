% function out = vceil(mat)
%
%   Rounds the elements of a VARYING/CONSTANT matrix MAT
%   to the nearest integer towards infinity. Identical
%   to MATLAB's CEIL command, but works with VARYING
%   matrices also.
%
%   See also: CEIL, FLOOR, and VFLOOR.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vceil(mat)
  if nargin == 0
    disp('usage: out = vceil(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mtype == 'vary'
    [nr,nc] = size(mat);
  out = [ceil(mat(1:nr-1,1:nc-1))  mat(1:nr-1,nc); ...
          mat(nr,1:nc)];
  elseif mtype == 'syst'
    error('VCEIL is undefined for SYSTEM matrices')
    return
  elseif mtype == 'cons'
    out = ceil(mat);
  else
    out = [];
  end
%
%