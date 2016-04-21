function cplxmap(z,w,B)
%CPLXMAP Plot a function of a complex variable.
%   CPLXMAP(z,f(z),(optional bound))
%   Used by CPLXDEMO.
%
%   See also CPLXGRID.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 03:30:08 $

blue = 0.2;
x = real(z);
y = imag(z);
u = real(w);
v = imag(w);

if nargin > 2
   k = find((abs(w) > B) | isnan(abs(w)));
   if length(k) > 0
      u(k) = B*sign(u(k));
      v(k) = zeros(size(k));
      v = v/max(max(abs(v)));
      v(k) = NaN*ones(size(k));
   end
end
      
M = max(max(u));
m = min(min(u));
axis([-1 1 -1 1 m M]);
caxis([-1 1]);
s = ones(size(z));
mesh(x,y,m*s,blue*s);
hold on
surf(x,y,u,v);
hold off
colormap(hsv(64))
