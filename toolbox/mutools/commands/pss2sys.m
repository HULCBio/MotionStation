% function sys = pss2sys(mat,n)
%
%   Converts a CONSTANT matrix into a SYSTEM matrix with n
%   states. assumes that the constant matrix has the state
%   space data in the form  mat = [A B;C D], and that the
%   matrix A is n x n.
%
%   See also: MINFO, PCK, ND2SYS, SYS2PSS, UNPCK, and ZP2SYS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sys = pss2sys(mat,n)
 if nargin ~= 2
   disp('usage: sys = pss2sys(mat,n)');
   return
 end
 [nr,nc] = size(mat);
 if n < min([nr nc])
   sys = pck(mat(1:n,1:n),mat(1:n,n+1:nc),mat(n+1:nr,1:n),mat(n+1:nr,n+1:nc));
 else
   error('insufficient rows/columns for given number of states')
   return
 end
%
%