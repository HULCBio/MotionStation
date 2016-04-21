function r = specular(nx,ny,nz,s,v,k)
%SPECULAR Specular reflectance.
%   R = SPECULAR(Nx,Ny,Nz,S,V) returns the reflectance of a surface with
%   normal vector components [Nx,Ny,Nz].  S and V specify the direction
%   to the light source and to the viewer, respectively. They can be
%   three vectors [x,y,z] or two vectors [Theta Phi] (in spherical 
%   coordinates).
%
%   The specular highlight is strongest when the normal vector is in the 
%   direction of (S+V)/2 where S is the source direction, and V is the 
%   view direction.
%
%   The surface spread exponent can be specified by including a sixth
%   argument as in specular(Nx,Ny,Nz,S,V,spread).
%
%   See also DIFFUSE, SURFNORM, SURFL.

%   Clay M. Thompson 5-1-91
%   Revised 4-21-92 by cmt
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:27:51 $

error(nargchk(5,6,nargin));

if nargin<6
  k = 10; % Surface spread exponent.
end

[m,n] = size(nx);
if ~isequal(size(ny),[m,n]), error('Ny must be the same size as Nx.'); end
if ~isequal(size(nz),[m,n]), error('Nz must be the same size as Nx.'); end

if length(s)==2, % Compute source direction from [AZ,EL]
  az = s(1)*pi/180; el = s(2)*pi/180; % Convert to radians
  s = [sin(az)*cos(el); -cos(az)*cos(el); sin(el)];
elseif length(s)==3 
  s = s(:)/norm(s); % Normalize
else
  error('S must be specified using [AZ,EL] or [Sx,Sy,Sz].');
end

if length(v)==2, % Compute view direction from [AZ,EL]
  az = v(1)*pi/180; el = v(2)*pi/180; % Convert to radians
  v = [sin(az)*cos(el); -cos(az)*cos(el); sin(el)];
elseif length(v)==3 
  v = v(:)/norm(v); % Normalize
else
  error('V must be specified using [AZ,EL] or [Vx,Vy,Vz].');
end

% Create view direction matrices
vx = v(1)*ones(m,n);
vy = v(2)*ones(m,n);
vz = v(3)*ones(m,n);

% Create source direction matrices
sx = s(1)*ones(m,n);
sy = s(2)*ones(m,n);
sz = s(3)*ones(m,n);

% Normal vectors magnitude
mag = nx.*nx + ny.*ny + nz.*nz;
d = find(mag==0); mag(d) = eps*ones(size(d));

r = max(0,2*(sx.*nx+sy.*ny+sz.*nz).*(vx.*nx+vy.*ny+vz.*nz)./mag - ...
    (v'*s)*ones(m,n));
r = r.^k;
