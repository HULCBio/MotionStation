% function out = spoles(sys)
%
%   Eigenvalues of the A matrix of a SYSTEM matrix.
%
%   See also: EIG, RIFD and SZEROS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%   modified (RSS, 6/11/92).  A schur method is used
%   to determine the eigenvalues.

function out = spoles(sys)
 if nargin ~= 1
   disp('usage: out = spoles(sys)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 if mtype == 'syst'
   if mnum == 0
     disp('input matrix has no states')
   else
     [U,as] = schur(sys(1:mnum,1:mnum));
     [U,asc] = rsf2csf(U,as);
     out = asc([1:mnum+1:mnum^2]');
   end
 else
   error('input matrix is not a SYSTEM matrix')
   return
 end