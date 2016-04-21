function [xx,yy,zz]=ellipsoid(varargin)
%ELLIPSOID Generate ellipsoid.
%   [X,Y,Z]=ELLIPSOID(XC,YC,ZC,XR,YR,ZR,N) generates three
%   (N+1)-by-(N+1) matrices so that SURF(X,Y,Z) produces an
%   ellipsoid with center (XC,YC,ZC) and radii XR, YR, ZR.
% 
%   [X,Y,Z]=ELLIPSOID(XC,YC,ZC,XR,YR,ZR) uses N = 20.
%
%   ELLIPSOID(...) and ELLIPSOID(...,N) with no output arguments
%   graph the ellipsoid as a SURFACE and do not return anything.
%
%   ELLIPSOID(AX,...) plots into AX instead of GCA.
%
%   The ellipsoidal data is generated using the equation:
%
%    (X-XC)^2     (Y-YC)^2     (Z-ZC)^2
%    --------  +  --------  +  --------  =  1
%      XR^2         YR^2         ZR^2
%
%   See also SPHERE, CYLINDER.

%   Laurens Schalekamp and Damian T. Packer
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2002/09/26 01:55:22 $

% Parse possible Axes input
error(nargchk(6,8,nargin));
[cax,args,nargs] = axescheck(varargin{:});

[xc,yc,zc,xr,yr,zr] = deal(args{1:6});
n  = 20;

if nargs > 6
	n = args{7}; 
end

[x,y,z] = sphere(n);

x = xr*x+xc;
y = yr*y+yc;
z = zr*z+zc;
if(nargout == 0)
    cax = newplot(cax);
	surf(x,y,z,'parent',cax)
else
	xx=x;
	yy=y;
	zz=z;
end
