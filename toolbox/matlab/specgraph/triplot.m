function hh = triplot(tri,x,y,varargin)
%TRIPLOT 2-D Triangular plot.
%   TRIPLOT(TRI,X,Y) displays the triangles defined in the
%   M-by-3 matrix TRI.  A row of TRI contains indices into X,Y that
%   define a single triangle. The default line color is blue.
%
%   TRIPLOT(TRI,X,Y,COLOR) uses the string COLOR as the line color.
%
%   H = TRIPLOT(...) returns a vector of handles to the displayed triangles.
%
%   TRIPLOT(...,'param','value','param','value'...) allows additional
%   line param/value pairs to be used when creating the plot.
%
%   Example:
%
%   rand('state',0);
%   x = rand(1,10);
%   y = rand(1,10);
%   tri = delaunay(x,y);
%   triplot(tri,x,y)
%
%   See also TRISURF, TRIMESH, DELAUNAY.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/06/17 13:39:23 $

start = 1;
if nargin < 3
  error('Not enough input arguments.');
elseif (nargin == 3) | (mod(nargin-3,2) == 0)
  c = 'blue';
else
  c = varargin{1};
  start = 2;
end

d = tri(:,[1 2 3 1])';
h = plot(x(d), y(d),c,varargin{start:end});
if nargout == 1, hh = h; end
