% function out = vebe(oper,mat)
%
%   Element-by-element operation on a VARYING/CONSTANT matrix,
%   using standard MATLAB arithmetic functions with one input
%   argument, such as SIN, ABS, REAL, SQRT, LOG, GAMMA, etc.
%   OPER needs to be a character string, i.e. 'sin', 'abs', etc.
%
%   See also: EBE, VABS, VDET, VDIAG, VREAL and VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vebe(oper,mat)
 if nargin <= 1
   disp('usage: out = vebe(oper,mat)')
   return
 end
 if ~isstr(oper)
   error(['first argument in VEBE should be a character string']);
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   [nr,nc] = size(mat);
   eval(['out = [' oper '(mat(1:nr-1,1:nc-1)) mat(1:nr-1,nc);mat(nr,1:nc)];']);
 elseif mtype == 'syst'
   error('VEBE is undefined for SYSTEM matrices')
   return
 else
   eval(['out = ' oper '(mat);']);
 end
%
%