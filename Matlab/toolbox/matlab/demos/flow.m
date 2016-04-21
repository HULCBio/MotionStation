function [x,y,z,v] = flow(x,y,z)
%FLOW A simple function of 3 variables.
%   FLOW, a function of three variables, generates fluid flow data 
%   that is useful for demonstrating SLICE, INTERP3, and other 
%   functions that visualize scalar volume data.
%   
%   There are several variants of the calling sequence:
%       V = FLOW; produces a 50-by-25-by-25 array.
%       V = FLOW(N) produces a 2N-by-N-by-N array.
%       V = FLOW(X,Y,Z) evaluates the speed profile at the points (X,Y,Z).
%       [X,Y,Z,V] = FLOW(...) returns the coordinates as well.

%   Reference: Fluid Mechanics, L. D. Landau and E. M. Lifshitz.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $ $Date: 2004/04/10 23:24:42 $

if nargin==0,
  [x,y,z] = meshgrid(.1:.2:10,-3:.25:3,-3:.25:3);
elseif nargin==1, % flow(N)
  n = x;
  [x,y,z] = meshgrid(linspace(.1,10,2*n),linspace(-3,3,n),linspace(-3,3,n));
elseif nargin==2, 
  error('Wrong number of input arguments.');
end

% Convert to spherical coordinates (with x as the axis).
A = 2; nu = 1;

[th,phi,r] = cart2sph(y,z,x);
vr = 2*nu/r.*((A^2-1)/(A-cos(phi)).^2 - 1);
vphi = -2*nu*sin(phi)./(A-cos(phi))./r;
vth = zeros(size(r));

[vx,vy,vz] = sph2cart(vth,vphi,vr);
v = log(sqrt(vx.^2 + vy.^2 + vz.^2));

if nargout < 2, x = v; end
