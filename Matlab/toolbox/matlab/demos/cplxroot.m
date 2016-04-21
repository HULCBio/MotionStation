function cplxroot(n,m)
%CPLXROOT Riemann surface for the n-th root.
%   CPLXROOT(n) renders the Riemann surface for the n-th root.
%   CPLXROOT, by itself, renders the Riemann surface for the cube root.
%   CPLXROOT(n,m) uses an m-by-m grid.  Default m = 20.

%   C. B. Moler, 8-17-89, 7-20-91.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 03:30:16 $

% Use polar coordinates, (r,theta).
% Cover the unit disc n times.

if nargin < 1, n = 3; end
if nargin < 2, m = 20; end
r = (0:m)'/m;
theta = pi*(-n*m:n*m)/m;
z = r * exp(i*theta);
s = r.^(1/n) * exp(i*theta/n);

surf(real(z),imag(z),real(s),imag(s));
