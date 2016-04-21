function y = betacore(x, a, b)
%BETACORE Core algorithm for the incomplete beta function.
%   BETACORE(x,a,b) is used twice by BETAINC(X,A,B).
%   Returns NaN if continued fraction does not converge.
%
%   See also BETAINC.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/12/26 18:09:16 $

qab = a + b;
qap = a + 1;
qam = a - 1;
am = 1;
bm = am;
y = am;
bz = 1 - qab .* x ./ qap;
d = 0;
app = d;
ap = d;
bpp = d;
bp = d;
yold = d;
m = 1;
k = 1;
while 1
   tem = 2 * m;
   d = m * (b - m) .* x ./ ((qam + tem) .* (a + tem));
   ap = y + d .* am;
   bp = bz + d .* bm;
   d = -(a + m) .* (qab + m) .* x ./ ((a + tem) .* (qap + tem));
   app = ap + d .* y;
   bpp = bp + d .* bz;
   yold = y;
   am = ap ./ bpp;
   bm = bp ./ bpp;
   y = app ./ bpp;
   if m == 1
      bz = 1;
   end
   k = find(abs(y(:)-yold(:)) > 1000*eps(y(:)));
   if isempty(k)
      break
   end
   m = m + 1;
   if m > 1000
      y(k) = NaN;
      return
   end
end
