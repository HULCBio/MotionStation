% function sysout = sresid(sys,ord)
%
%   Residulizes the input SYSTEM SYS of order N to a SYSTEM, SYSOUT
%   of order ORD.  SRESID assumes that the system matrix has been
%   ordered such that the last (N-ORD) states are to be residulized.
%
%   See also: RIFD, STRANS, STATECC, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sysout = sresid(sys,ord)
 if nargin ~= 2
   disp('usage: sysout = sresid(sys,ord)')
   return
 end
if isempty(ord)
   return
 end
 if ord < 0 | (floor(ord) ~= ceil(ord))
   error(['ORD should be a nonnegative integer'])
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 if mtype == 'syst'
   if ord > mnum
     ord = mnum
   end
   if mnum == 0
     disp('input matrix has no states')
   else
     sysout = zeros((ord+mrows+1),(ord+mcols+1));
     sysout(1,ord+mcols+1) = ord;
     sysout((ord+mrows+1),(ord+mcols+1)) = -Inf;
     n11 = ord;
     abcd = sys([1:n11 (mnum+1):(mnum+mrows)],[1:n11 (mnum+1):(mnum+mcols)]);
     a12c2 = sys([1:n11 (mnum+1):(mnum+mrows)],[(n11+1):mnum]);
     a21b2 = sys([(n11+1):mnum],[1:n11 (mnum+1):(mnum+mcols)]);
     a22 = sys((n11+1):mnum,(n11+1):mnum);
     sysout(1:ord+mrows,1:ord+mcols) = abcd-a12c2*(a22\a21b2);
   end
 else
   error('input matrix is not a SYSTEM matrix')
   return
 end
%
%