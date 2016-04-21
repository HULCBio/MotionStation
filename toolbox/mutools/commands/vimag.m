% function out = vimag(mat)
%
%   Imaginary part of VARYING/CONSTANT matrix. Identical
%   to MATLAB's IMAG command, but VIMAG works on VARYING
%   matrices also.
%
%   See also: IMAG, REAL, VEBE, VEVAL, and VREAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vimag(mat)
 if nargin ~= 1
   disp('usage: out = vimag(mat)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   [nr,nc] = size(mat);
   out = [imag(mat(1:nr-1,1:nc-1))  mat(1:nr-1,nc);...
           mat(nr,1:nc)];
 elseif mtype == 'syst'
   error('VIMAG is undefined for SYSTEM matrices')
   return
 else
   out = imag(mat);
 end
%
%