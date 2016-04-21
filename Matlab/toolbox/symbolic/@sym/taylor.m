function t = taylor(varargin)
%TAYLOR Taylor series expansion.
%   TAYLOR(f) is the fifth order Maclaurin polynomial approximation to f.
%   Three additional parameters can be specified, in almost any order.
%   TAYLOR(f,n) is the (n-1)-st order Maclaurin polynomial.
%   TAYLOR(f,a) is the Taylor polynomial approximation about point a.
%   TAYLOR(f,x) uses the independent variable x instead of FINDSYM(f).
%
%   Examples:
%      taylor(exp(-x))   returns
%         1-x+1/2*x^2-1/6*x^3+1/24*x^4-1/120*x^5
%      taylor(log(x),6,1)   returns
%         x-1-1/2*(x-1)^2+1/3*(x-1)^3-1/4*(x-1)^4+1/5*(x-1)^5
%      taylor(sin(x),pi/2,6)   returns
%         1-1/2*(x-1/2*pi)^2+1/24*(x-1/2*pi)^4
%      taylor(x^t,3,t)   returns
%         1+log(x)*t+1/2*log(x)^2*t^2
%
%   See also FINDSYM, SYMSUM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/16 22:23:14 $

if nargin >= 5
   error('symbolic:sym:taylor:errmsg1','TAYLOR can be called with at most 4 input arguments');
end

f = sym(varargin{1});
n = NaN;
a = '';
x = '';
for k = 2:nargin
   v = varargin{k};
   if isa(v,'double')
      if (v == fix(v)) & (v > 0) & isnan(n)
         n = v;
      else
         a = char(sym(v));
      end
   else
      v = char(sym(v));
      if findstr(v,findsym(f))
         x = v;
      else
         a = v;
      end
   end
end
if isnan(n)
   n = 6;
end
if isempty(x)
   x = findsym(f,1);
end
if ~isempty(a)
   x = [x '=' a];
end
[t,stat] = maple('taylor',f,x,n);
if stat, error('symbolic:sym:taylor:errmsg2',t); end
t = maple('convert',t,'polynom');
