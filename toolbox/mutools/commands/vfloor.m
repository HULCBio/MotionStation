% function out = vfloor(mat)
%
%   Rounds the elements of a VARYING/CONSTANT matrix MAT
%   to the nearest integer towards minus infinity. Identical
%   to MATLAB's FLOOR command, but works with VARYING
%   matrices also.
%
%   See also: CEIL, FLOOR, and VCEIL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vfloor(mat)
  if nargin == 0
    disp('usage: out = vfloor(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mtype == 'vary'
    [nr,nc] = size(mat);
  out = [floor(mat(1:nr-1,1:nc-1))  mat(1:nr-1,nc); ...
          mat(nr,1:nc)];
  elseif mtype == 'syst'
    error('VFLOOR is undefined for SYSTEM matrices')
    return
  elseif mtype == 'cons'
    out = floor(mat);
  else
    out = [];
  end
%
%