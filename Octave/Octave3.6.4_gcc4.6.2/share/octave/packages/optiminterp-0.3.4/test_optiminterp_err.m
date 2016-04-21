%% Copyright (C) 2006 Alexander Barth <barth.alexander@gmail.com>
%%
%% This program is free software; you can redistribute it and/or modify it under
%% the terms of the GNU General Public License as published by the Free Software
%% Foundation; either version 3 of the License, or (at your option) any later
%% version.
%%
%% This program is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public License along with
%% this program; if not, see <http://www.gnu.org/licenses/>.

% Tests 2D optimal interpolation and compares result 
% (analysis and error field) to global OI solution

printf('Testing 2D-optimal interpolation (analysis and error field): ');


% grid of background field
[xi,yi] = ndgrid(linspace(0,1,30));
fi_ref = sin( xi*6 ) .* cos( yi*6);


% grid of observations
[x,y] = ndgrid(linspace(0,1,6));
x = x(:);
y = y(:);

on = numel(x);
var = 0.01 * ones(on,1);
f = sin( x*6 ) .* cos( y*6);

len = 0.1;
m = min(30,on);

% covariance function
% gaussian
%bcovar2 = @(d2) exp(-d2/len^2) ;
% diva
bcovar2 = @(d2) max(sqrt(d2)/len,eps) .* besselk(1,max(sqrt(d2)/len,eps));

% P: covariance between grid points (xi,yi) and grid points (xi,yi)
P = zeros(numel(xi),numel(xi));

for j=1:numel(xi)
  for i=1:numel(xi) 
    P(i,j) = (xi(i) - xi(j))^2 + (yi(i) - yi(j))^2;
  end
end
P = bcovar2(P);

% HPH: covariance between observation points (x,y) and observation points (x,y)
HPH = zeros(numel(x),numel(x));

for j=1:numel(x)
  for i=1:numel(x)
    HPH(i,j) = (x(i) - x(j))^2 + (y(i) - y(j))^2;
  end
end
HPH = bcovar2(HPH);

% PH: covariance between grid points (xi,yi) and observation points (x,y)
PH = zeros(numel(xi),numel(x));

for j=1:numel(x)
  for i=1:numel(xi) 
    PH(i,j) = (xi(i) - x(j))^2 + (yi(i) - y(j))^2;
  end
end
PH = bcovar2(PH);

R = diag(var);

% call optiminterp
[fi,vari] = optiminterp2(x,y,f,var,len,len,m,xi,yi);

% Kalman gain
K = PH * inv(HPH + R);

% analysis
fi2 = K * f;

% error field
vari2 = diag(P - K * PH');

% transform vectors into 2d-arrays
fi2 = reshape(fi2,size(fi));
vari2 = reshape(vari2,size(fi));

rms = sqrt(mean((fi2(:) - fi(:)).^2));

if rms > 1e-4
  error('unexpected large RMS difference (analysis)');
end

rms = sqrt(mean((vari2(:) - vari(:)).^2));

if rms > 1e-4
  error('unexpected large RMS difference (error field)');
end

disp('OK');
