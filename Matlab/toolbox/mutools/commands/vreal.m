% function out = vreal(mat)
%
%   Real part of VARYING/CONSTANT matrix, identical
%   to MATLAB's REAL command, but VREAL works on
%   VARYING matrices also.
%
%   See also: ABS, IMAG, REAL, VABS, VEBE, VEVAL, and VIMAG.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vreal(mat)
 if nargin ~= 1
   disp('usage: out = vreal(mat)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   [nr,nc] = size(mat);
   out = [real(mat(1:nr-1,1:nc-1))  mat(1:nr-1,nc);...
           mat(nr,1:nc)];
 elseif mtype == 'syst'
   error('VREAL is undefined for SYSTEM matrices')
   return
 else
   out = real(mat);
 end
%
%