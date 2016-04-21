function [xx,yy,zz] = cylinder(varargin)
%CYLINDER Generate cylinder.
%   [X,Y,Z] = CYLINDER(R,N) forms the unit cylinder based on the generator
%   curve in the vector R. Vector R contains the radius at equally
%   spaced points along the unit height of the cylinder. The cylinder
%   has N points around the circumference. SURF(X,Y,Z) displays the
%   cylinder.
%
%   [X,Y,Z] = CYLINDER(R), and [X,Y,Z] = CYLINDER default to N = 20
%   and R = [1 1].
%
%   Omitting output arguments causes the cylinder to be displayed with
%   a SURF command and no outputs to be returned.
%
%   CYLINDER(AX,...) plots into AX instead of GCA.
%
%   See also SPHERE, ELLIPSOID.

%   Clay M. Thompson 4-24-91, CBM 8-21-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8.4.1 $  $Date: 2002/09/26 01:55:21 $

% Parse possible Axes input
error(nargchk(0,3,nargin));
[cax,args,nargs] = axescheck(varargin{:});

n = 20;
r = [1 1]';
if nargs > 0, r = args{1}; end
if nargs > 1, n = args{2}; end
r = r(:); % Make sure r is a vector.
m = length(r); if m==1, r = [r;r]; m = 2; end
theta = (0:n)/n*2*pi;
sintheta = sin(theta); sintheta(n+1) = 0;

x = r * cos(theta);
y = r * sintheta;
z = (0:m-1)'/(m-1) * ones(1,n+1);

if nargout == 0
    cax = newplot(cax);
    surf(x,y,z,'parent',cax)
else
    xx = x; yy = y; zz = z;
end
