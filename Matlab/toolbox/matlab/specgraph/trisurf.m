function hh = trisurf(tri,x,y,z,varargin)
%TRISURF Triangular surface plot.
%   TRISURF(TRI,X,Y,Z,C) displays the triangles defined in the M-by-3
%   face matrix TRI as a surface.  A row of TRI contains indexes into
%   the X,Y, and Z vertex vectors to define a single triangular face.
%   The color is defined by the vector C.
%
%   TRISURF(TRI,X,Y,Z) uses C = Z, so color is proportional to surface
%   height.
%
%   H = TRISURF(...) returns a patch handle.
%
%   TRISURF(...,'param','value','param','value'...) allows additional
%   patch param/value pairs to be used when creating the patch object. 
%
%   Example:
%
%   [x,y]=meshgrid(1:15,1:15);
%   tri = delaunay(x,y);
%   z = peaks(15);
%   trisurf(tri,x,y,z)
%
%   See also PATCH, TRIMESH, DELAUNAY.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/06/17 13:38:33 $


ax = newplot;
start = 1;
if nargin>4 & rem(nargin-4,2)==1, 
  c = varargin{1};
  start = 2;
elseif nargin<4
  error('Not enough input arguments');
else
  c = z;
end

h = patch('faces',tri,'vertices',[x(:) y(:) z(:)],'facevertexcdata',c(:),...
      'facecolor',get(ax,'defaultsurfacefacecolor'), ...
      'edgecolor',get(ax,'defaultsurfaceedgecolor'),varargin{start:end});
if ~ishold, view(3), grid on, end
if nargout==1, hh = h; end
