function r = symsum(f,x,a,b)
%SYMSUM Symbolic summation.
%   SYMSUM(S) is the indefinite summation of S with respect to the
%   symbolic variable determined by FINDSYM.
%   SYMSUM(S,v) is the indefinite summation with respect to v.
%   SYMSUM(S,a,b) and SYMSUM(S,v,a,b) are the definite summation from a to b.
%
%   Examples:
%      simple(symsum(k))             1/2*k*(k-1)
%      simple(symsum(k,0,n-1))       1/2*n*(n-1)
%      simple(symsum(k,0,n))         1/2*n*(n+1)
%      simple(symsum(k^2,0,n))       1/6*n*(n+1)*(2*n+1)
%      symsum(k^2,0,10)              385
%      symsum(k^2,11,10)             0
%      symsum(1/k^2)                 -Psi(1,k)
%      symsum(1/k^2,1,Inf)           1/6*pi^2
%
%   See also INT.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:10:21 $

if nargin == 1
   f = sym(f);
   x = findsym(f,1);
end

if nargin <= 2
   % Indefinite summation
   r = maple('map','sum',f,x);

else
   % Definite summation
   if nargin == 3
      b = a;
      a = x;
      x = findsym(f,1);
      if isempty(x), x = 'x'; end
   end
   x = sym(x);
   a = sym(a);
   b = sym(b);
   r = maple('map','sum',f,[x.s '=' a.s '..' b.s]);
end
