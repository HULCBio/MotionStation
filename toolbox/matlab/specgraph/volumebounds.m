function ret = volumebounds(x,y,z,u,v,w) 
%VOLUMEBOUNDS  Returns x,y,z and color limits for volume data.
%   LIMS = VOLUMEBOUNDS(X,Y,Z,V) returns the x,y,z and color limits
%   of the current axes for scalar data. LIMS is returned as a
%   vector: [xmin xmax ymin ymax zmin zmax cmin cmax]. This vector
%   can be passed to the AXIS command.
%
%   LIMS = VOLUMEBOUNDS(X,Y,Z,U,V,W) returns the x,y,z limits of
%   the current axes for vector data.  LIMS is returned as a
%   vector: [xmin xmax ymin ymax zmin zmax]. 
%
%   VOLUMEBOUNDS(V) or VOLUMEBOUNDS(U,V,W) assumes 
%      [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(V). 
%
%   Example:
%      [x y z v] = flow;
%      p = patch(isosurface(x, y, z, v, -3));
%      isonormals(x,y,z,v, p)
%      daspect([1 1 1])
%      isocolors(x,y,z,flipdim(v,2),p)
%      shading interp
%      axis(volumebounds(x,y,z,v))
%      view(3)
%      camlight 
%      lighting phong
%
%   See also ISOSURFACE, STREAMSLICE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/06/17 13:39:20 $

if nargin==1         % VOLUMEBOUNDS(V)
  v = x;
  ret = [1 size(v,2) 1 size(v,1) 1 size(v,3) min(v(:)) max(v(:))];
elseif nargin==3     % VOLUMEBOUNDS(U,V,W)
  v = x;
  ret = [1 size(v,2) 1 size(v,1) 1 size(v,3)]; 
elseif nargin==4     % VOLUMEBOUNDS(X,Y,Z,V) 
  v = u;
  ret = [min(x(:)) max(x(:)) min(y(:)) max(y(:)) min(z(:)) max(z(:))...
  	 min(v(:)) max(v(:))];
elseif nargin==6     % VOLUMEBOUNDS(X,Y,Z,U,V,W) 
  ret = [min(x(:)) max(x(:)) min(y(:)) max(y(:)) min(z(:)) max(z(:))];
else
  error('Wrong number of input arguments.'); 
end
