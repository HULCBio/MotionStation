function R = diff(varargin)
%DIFF   Differentiate.
%   DIFF(S) differentiates a symbolic expression S with respect to its
%   free variable as determined by FINDSYM.
%   DIFF(S,'v') or DIFF(S,sym('v')) differentiates S with respect to v.
%   DIFF(S,n), for a positive integer n, differentiates S n times.
%   DIFF(S,'v',n) and DIFF(S,n,'v') are also acceptable.
%
%   Examples;
%      x = sym('x');
%      t = sym('t');
%      diff(sin(x^2)) is 2*cos(x^2)*x
%      diff(t^6,6) is 720.
%
%   See also INT, JACOBIAN, FINDSYM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/16 22:22:14 $

if nargin >= 4
   error('symbolic:sym:diff:errmsg1','DIFF can be called with at most 3 input arguments');
end

S = sym(varargin{1});
n = 1;
x = [];
for j = 2:nargin
   a = varargin{j};
   if isa(a,'sym')
      x = a.s;
   elseif isvarname(a)
      x = a;
   elseif isa(a,'double') & length(a) == 1
      n = a;
   else
      error('symbolic:sym:diff:errmsg2','Do not recognize argument number %d.',j)
   end
end
if isempty(x)
   x = findsym(S,1);
end
if isempty(x)
   R = 0*S;
elseif n == 0
   R = S;
else
   if n > 1
      x = [x '$' int2str(n)];
   end
   R = reshape(maple('map','diff',S(:),x),size(S));
end
