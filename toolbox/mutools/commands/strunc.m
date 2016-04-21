% function sysout = strunc(sys,ord)
%
%   Truncates the state dimension of a SYSTEM
%   matrix to ORD states, by eliminating rows
%   and columns of the state matrices.
%
%   See also: HANKMR, REORDSYS, SRESID, and SYSBAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sysout = strunc(sys,ord)
 if nargin ~= 2
   disp(['usage: sysout = strunc(sys,ord)']);
   return
 end
 if isempty(ord)
   return
 end
 if ord < 0 | (floor(ord) ~= ceil(ord))
   error(['ord should be a nonnegative integer'])
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 if mtype == 'syst'
   if ord > mnum
     ord = mnum
   end
   sysout = sys([1:ord mnum+1:mnum+mrows+1],[1:ord mnum+1:mnum+mcols+1]);
   sysout(1,ord+mcols+1) = ord;
 else
   error(['input matrix is not a SYSTEM matrix'])
   return
 end
%
%