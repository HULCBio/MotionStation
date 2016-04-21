function [xx,yy,zz] = superquad(n,e,m)
%SUPERQUAD Barr's "superquadrics" ellipsoid.
%   [x,y,z] = SUPERQUAD(n,e,m) is a generalized ellipsoid with
%   n = vertical roundness, e = horizontal roundness and m facets.
%   If values of n and e are not given, random values are supplied.
%   The default value of m is 24.
%
%   SUPERQUAD(...) , with no output arguments, does a SURF plot.
%
%   Ref: A. H. Barr, IEEE Computer Graphics and Applications, 1981,
%        or, Graphics Gems III, David Kirk, editor, 1992.
%
%   See also XPQUAD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/10 23:25:49 $

if nargin < 3, m = 24; end
if nargin < 2, e = max(0,1+randn); end
if nargin < 1, n = max(0,1+randn); end

u = (-m:2:m)/m*pi;
v = u'/2;

cosv = cos(v); sinv = sin(v);
cosu = cos(u); sinu = sin(u);
cosv(1) = 0; cosv(m+1) = 0;
sinu(1) = 0; sinu(m+1) = 0;

t = sign(cosv) .* abs(cosv).^n ;
x = t * (sign(cosu) .* abs(cosu).^e );
y = t * (sign(sinu) .* abs(sinu).^e );
z = (sign(sinv) .* abs(sinv).^n ) *  ones(size(u));

if nargout == 0
   surf(x,y,z)
else
   xx = x; yy = y; zz = z;
end
