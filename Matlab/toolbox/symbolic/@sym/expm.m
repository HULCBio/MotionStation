function Y = expm(X)
%EXPM   Symbolic matrix exponential.
%   EXPM(A) is the matrix exponential of the symbolic matrix A.
%
%   Examples:
%      syms t
%      A = [0 1; -1 0]
%      expm(t*A)
%
%      A = sym(gallery(5))
%      expm(t*A)

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:22:22 $

if all(size(X) == 1)
   Y = maple('exp',X);
elseif size(X,1) == size(X,2)
   [Y,stat] = maple(['evalm(exponential(' char(X) '));']);
   if stat | strncmp(char(Y),'exponential',11)
      Y = sym([]);
      warning('symbolic:sym:expm:warnmsg1','Explicit matrix exponential could not be found.')
   else
      Y = sym(Y);
   end
else
   error('symbolic:sym:expm:errmsg1','Matrix must be square.')
end