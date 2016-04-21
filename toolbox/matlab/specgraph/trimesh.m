function hh = trimesh(tri,x,y,z,varargin)
%TRIMESH Triangular mesh plot.
%   TRIMESH(TRI,X,Y,Z,C) displays the triangles defined in the M-by-3
%   face matrix TRI as a mesh.  A row of TRI contains indexes into
%   the X,Y, and Z vertex vectors to define a single triangular face.
%   The edge color is defined by the vector C.
%
%   TRIMESH(TRI,X,Y,Z) uses C = Z, so color is proportional to surface
%   height.
%
%   TRIMESH(TRI,X,Y) displays the triangles in a 2-d plot.
%
%   H = TRIMESH(...) returns a handle to the displayed triangles.
%
%   TRIMESH(...,'param','value','param','value'...) allows additional
%   patch param/value pairs to be used when creating the patch object. 
%
%   Example:
%
%   [x,y]=meshgrid(1:15,1:15);
%   tri = delaunay(x,y);
%   z = peaks(15);
%   trimesh(tri,x,y,z)
%
%   See also PATCH, TRISURF, DELAUNAY.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/06/17 13:38:25 $

if nargin == 3 | (nargin > 4 & isstr(z))
  d = tri(:,[1 2 3 1])';
  if nargin == 3
    h = plot(x(d), y(d));
  else
    h = plot(x(d), y(d),z,varargin{1},varargin{2:end});
  end
  if nargout == 1, hh = h; end
  return;
end

start = 1;
if nargin>4 & rem(nargin-4,2)==1, 
  c = varargin{1};
  start = 2;
elseif nargin<3
  error('Not enough input arguments');
else
  c = z;
end

ax = newplot;
if isstr(get(ax,'color')),
  fc = get(gcf,'Color');
else
  fc = get(ax,'color');
end

h = patch('faces',tri,'vertices',[x(:) y(:) z(:)],'facevertexcdata',c(:),...
	  'facecolor',fc,'edgecolor',get(ax,'defaultsurfacefacecolor'),...
	  'facelighting', 'none', 'edgelighting', 'flat',...
	  varargin{start:end});
if ~ishold, view(3), grid on, end
if nargout == 1, hh = h; end
