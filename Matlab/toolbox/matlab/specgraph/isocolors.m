function fvcout=isocolors(varargin)
%ISOCOLORS  Isosurface and patch colors.
%   NC = ISOCOLORS(X,Y,Z,C,VERTICES) computes the colors of
%   isosurface (patch) vertices VERTICES by using color values C. 
%   Arrays X,Y,Z specify the points at which the data C is given.
%   X,Y,Z define the coordinates for C and must be monotonic
%   vectors or 3D plaid arrays (as if produced by MESHGRID). The
%   colors are returned in NC. C must be 3D (index colors).
%   
%   NC = ISOCOLORS(X,Y,Z,R,G,B,VERTICES) uses R,G,B red, green, and
%   blue color arrays.
%
%   NC = ISOCOLORS(C,VERTICES) or NC = ISOCOLORS(R,G,B,VERTICES)
%   assumes [X Y Z]=meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(C). 
%   
%   NC = ISOCOLORS(C,P), NC = ISOCOLORS(X,Y,Z,C,P), 
%   NC = ISOCOLORS(R,G,B,P), or NC = ISOCOLORS(X,Y,Z,R,G,B,P) uses
%   the vertices from patch P.
%   
%   ISOCOLORS(C,P), ISOCOLORS(X,Y,Z,C,P), ISOCOLORS(R,G,B,P), or
%   ISOCOLORS(X,Y,Z,R,G,B,P) sets the 'FaceVertexCdata' 
%   property of the patch specified in P with the computed colors. 
%
%   Example 1:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      cdata = smooth3(rand(size(data)), 'box', 7);
%      p = patch(isosurface(x,y,z,data, 10));
%      isonormals(x,y,z,data,p);
%      isocolors(x,y,z,cdata,p);
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);axis tight
%      camlight; lighting p; 
%
%   Example 2:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      p = patch(isosurface(x,y,z,data, 20));
%      isonormals(x,y,z,data,p);
%      [r g b] = meshgrid(20:-1:1, 1:20, 1:20);
%      isocolors(x,y,z,r/20,g/20,b/20,p);
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);
%      camlight; lighting p; 
%
%   Example 3:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      p = patch(isosurface(data, 20));
%      isonormals(data,p);
%      [r g b] = meshgrid(20:-1:1, 1:20, 1:20);
%      c=isocolors(r/20,g/20,b/20,p);
%      set(p, 'FaceVertexCdata', 1-c)
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);
%      camlight; lighting p; 
%
%   See also ISOSURFACE, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%            REDUCEPATCH, ISONORMALS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:38:58 $

[x y z c r g b verts] = parseargs(nargin,varargin);

% Take this out when other data types are handled
c = double(c);
r = double(r);
g = double(g);
b = double(b);

if ~isempty(c)
  [msg x y z] = xyzrgbcheck(x,y,z,c);  error(msg)
else
  [msg x y z] = xyzrgbcheck(x,y,z,r,g,b);  error(msg)
end  

if ishandle(verts)
  if strcmp(get(verts, 'type'), 'patch')
    p = verts;
    verts = get(p, 'vertices');
  else
    error('The handle supplied must be a patch handle');
  end
else
  p = [];
end

% if it's 2D, make it 3D
if size(verts,2)==2
  verts(:,3) = 0;
end


if isempty(verts)
  fvc = [];
else
 if isempty(x)
  if ~isempty(c)
    fvc=interp3(c, verts(:,1), verts(:,2), verts(:,3));
  else
    fvc(:,1)=interp3(r, verts(:,1), verts(:,2), verts(:,3));
    fvc(:,2)=interp3(g, verts(:,1), verts(:,2), verts(:,3));
    fvc(:,3)=interp3(b, verts(:,1), verts(:,2), verts(:,3));
  end
 else
  if ~isempty(c)
    fvc=interp3(x, y, z, c, verts(:,1), verts(:,2), verts(:,3));
  else
    fvc(:,1)=interp3(x, y, z, r, verts(:,1), verts(:,2), verts(:,3));
    fvc(:,2)=interp3(x, y, z, g, verts(:,1), verts(:,2), verts(:,3));
    fvc(:,3)=interp3(x, y, z, b, verts(:,1), verts(:,2), verts(:,3));
  end
 end
end

if nargout==0 
  if ~isempty(p)
    set(p, 'facevertexcdata', fvc)
  else
    fvcout = fvc;
  end
else
  fvcout = fvc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, data, r,g,b,verts] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
data = [];
r = [];
g = [];
b = [];
verts = [];

if nin==2      % isocolors(c, verts/p)
  data = vargin{1};
  verts = vargin{2};
elseif nin==4  % isocolors(r,g,b, verts/p)
  r = vargin{1};
  g = vargin{2};
  b = vargin{3};
  verts = vargin{4};
elseif nin==5  % isocolors(x,y,z,c, verts/p)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  verts = vargin{5};
elseif nin==7  % isocolors(x,y,z,r,g,b, verts/p)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  r = vargin{4};
  g = vargin{5};
  b = vargin{6};
  verts = vargin{7};
else
  error('Wrong number of input arguments.'); 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [msg,nx,ny,nz] = xyzrgbcheck(x,y,z,r,g,b)

msg = '';
nx = x;
ny = y;
nz = z;

sz = size(r);
if nargin>4
  if ~isequal(size(g), sz) | ~isequal(size(b), sz)
    msg='R,G,B must all be the same size.';
    return
  end
end  

if ndims(r)~=3
  msg='Color arrays must all be a 3D';
  return
end
if min(sz)<2
  msg = 'Color arrays must be size 2x2x2 or greater.'; 
  return
end

nonempty = ~[isempty(x) isempty(y) isempty(z)];
if any(nonempty) & ~all(nonempty)
  msg = 'X,Y,Z must all be empty or all non-empty.';
  return;
end

if ~isempty(nx) & ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg='The size of X must match the size of R or the number of columns of R.';
    return
  else
    nx = repmat(nx',[sz(1) 1 sz(3)]);
  end
end

if ~isempty(ny) & ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg='The size of Y must match the size of R or the number of rows of R.';
    return
  else
    ny = repmat(ny,[1 sz(2) sz(3)]);
  end
end

if ~isempty(nz) & ~isequal(size(nz), sz)
  nz = nz(:);
  if length(nz)~=sz(3)
    msg='The size of Z must match the size of R or the number of pages of R.';
    return
  else
    nz = repmat(reshape(nz,[1 1 length(nz)]),[sz(1) sz(2) 1]);
  end
end

