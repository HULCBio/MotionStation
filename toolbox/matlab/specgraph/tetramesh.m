function hh=tetramesh(tri,X,varargin)
%TETRAMESH Tetrahedron mesh plot.
%   TETRAMESH(T,X,C) displays the tetrahedrons defined in the M-by-4
%   matrix T as mesh.  T is usually the output of DELAUNAYN. A row of
%   T contains indices into X of the vertices of a tetrahedron. X
%   is an N-by-3 matrix, representing N points in 3 dimension. The
%   tetrahedron colors are defined by the vector C, which is used as
%   indices into the current colormap.
%
%   TETRAMESH(T,X) uses C=1:m as the color for the m tetrahedrons. Each
%   tetrahedron will have a different color (modula the number of
%   colors available in the current colormap).
%
%   H = TETRAMESH(...) returns a vector of tetrahedron handles. Each
%   element of H is a handle to the set of patches forming one
%   tetrahedron. One can use these handles to view a particular
%   tetrahedron by turning its 'visible' property 'on' and 'off'.
%
%   TETRAMESH(...,'param','value','param','value'...) allows
%   additional patch param/value pairs to be used when displaying the
%   tetrahedrons.  For example, the default transparency parameter is
%   set to 0.9.  You can overwrite this value by using the param pair
%   ('FaceAlpha', value). The value has to be a number between 0 and 1.
%
%   Example:
%
%   d = [-1 1];
%   [x,y,z] = meshgrid(d,d,d);  % A cube
%   x = [x(:);0];
%   y = [y(:);0];
%   z = [z(:);0];    % [x,y,z] are corners of a cube plus the center.
%   Tes = delaunay3(x,y,z)
%   X = [x(:) y(:) z(:)];
%   tetramesh(Tes,X);camorbit(20,0)
%
%   See also TRIMESH, TRISURF, PATCH, DELAUNAYN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/10 23:32:26 $

numtri = size(tri,1);

startparam = 1;
if nargin > 2 & rem(nargin-2,2) == 1
    c = varargin(1);
    c = c{1}(:);
    startparam = 2;
elseif nargin < 2
  error('Not enough input arguments.');
else
  c = 1:numtri;
end

if length(c) ~= numtri
  error('The number of colors should equal the number of tetrahedrons.');
end

cax = newplot;
hold_state = ishold(cax);
d = [1 1 1 2; 2 2 3 3; 3 4 4 4];
for i = 1:size(tri,1)
  y = tri(i,d);
  x1 = reshape(X(y,1),3,4);
  x2 = reshape(X(y,2),3,4);
  x3 = reshape(X(y,3),3,4);
  h(i)=patch(x1,x2,x3,[1 1 1 1]*c(i),'FaceAlpha', 0.9,...
             'Parent',cax,varargin{startparam:end});
end
if ~hold_state, 
    view(cax,3)
    axis(cax,'equal')
end

if nargout > 0
  hh = h;
end


