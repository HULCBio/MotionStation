% function out = vabs(mat)
%
%   Element-by-element absolute value of a
%   VARYING/CONSTANT matrix.
%
%   See also: ABS, VEBE, VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vabs(mat)
 if nargin ~= 1
   disp('usage: out = vabs(mat)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   [nr,nc] = size(mat);
   out = [abs(mat(1:nr-1,1:nc-1))  mat(1:nr-1,nc);...
           mat(nr,1:nc)];
 elseif mtype == 'syst'
   error('VABS is undefined for SYSTEM matrices')
   return
 elseif mtype == 'cons'
   out = abs(mat);
 else
   out = [];
 end
%
%