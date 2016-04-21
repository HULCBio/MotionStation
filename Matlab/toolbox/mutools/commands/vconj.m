% function out = vconj(mat)
%
%   Complex conjugate for VARYING/CONSTANT matrices, a
%   VARYING matrix version of MATLAB CONJ function.
%
%   See also: CONJ, VEBE, and VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vconj(mat)
 if nargin ~= 1
   disp('usage: out = vconj(mat)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   out = mat;
   out(1:mrows*mnum,1:mcols) = conj(mat(1:mrows*mnum,1:mcols));
 elseif mtype == 'syst'
   error('VCONJ is undefined for SYSTEM matrices')
 elseif mtype == 'cons'
   out = conj(mat);
 else
   out = [];
 end
%
%