function r = collect(s,x)
%COLLECT Collect coefficients.
%   COLLECT(S,v) regards each element of the symbolic matrix S as a
%   polynomial in v and rewrites S in terms of the powers of v.
%   COLLECT(S) uses the default variable determined by FINDSYM.
%
%   Examples:
%      collect(x^2*y + y*x - x^2 - 2*x)   returns   (y-1)*x^2+(y-2)*x
%
%      f = -1/4*x*exp(-2*x)+3/16*exp(-2*x)
%      collect(f,exp(-2*x))   returns   (-1/4*x+3/16)*exp(-2*x)
%
%   See also SIMPLIFY, SIMPLE, FACTOR, EXPAND, FINDSYM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:22:12 $

if nargin == 1
   x = findsym(s,1);
end
if numel(x) > 1
   x = char(x);
   if strncmp(x,'matrix([',8)
      x(1:8) = [];
      x(end-1:end) = [];
   end
   if strncmp(x,'array([',7)
      x(1:7) = [];
      x(end-1:end) = [];
   end
end
s = sym(s);
if numel(s) == 1
   r = maple('collect',s,x);
else
   r = reshape(maple('map','collect',s(:),x),size(s));
end
