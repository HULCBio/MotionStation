function nout=isonormals(varargin)
%ISONORMALS  Isosurface normals.
%   N = ISONORMALS(X,Y,Z,V,VERTICES) computes the normals of isosurface
%   vertices VERTICES by using the gradient of the data V. Arrays X, Y and Z
%   specify the points at which the data V is given. The normals are
%   returned in N. By default, the normals point in the direction of
%   smaller data values.
%   
%   N = ISONORMALS(V,VERTICES) assumes [X Y Z] = meshgrid(1:N, 1:M, 1:P)
%       where [M,N,P]=SIZE(V).
%   
%   N = ISONORMALS(V,P) or N = ISONORMALS(X,Y,Z,V,P) uses the vertices 
%       from patch P.
%   
%   N = ISONORMALS(..., 'negate') negates the computed normals.
%   
%   ISONORMALS(V,P) or ISONORMALS(X,Y,Z,V,P) sets the 'VertexNormals'
%   property of the patch specified in P with the computed normals.
%
%   Example:
%      data = cat(3, [0 .2 0; 0 .3 0; 0 0 0], ...
%                    [.1 .2 0; 0 1 0; .2 .7 0],...
%                    [0 .4 .2; .2 .4 0;.1 .1 0]);
%      data = interp3(data,3, 'cubic');
%      subplot(1,2,1)
%      p = patch(isosurface(data, .5), 'FaceColor', 'red', 'EdgeColor', 'none');
%      view(3); daspect([1 1 1]);axis tight
%      camlight;  camlight(-80,-10); lighting p; 
%      title('Triangle Normals')
%      subplot(1,2,2)
%      p = patch(isosurface(data, .5), 'FaceColor', 'red', 'EdgeColor', 'none');
%      isonormals(data,p)
%      view(3); daspect([1 1 1]); axis tight
%      camlight;  camlight(-80,-10); lighting phong; 
%      title('Data Normals')
%
%   See also ISOSURFACE, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%            REDUCEPATCH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/06/17 13:39:03 $

[x y z data verts negate] = parseargs(nargin,varargin);

% Take this out when other data types are handled
data = double(data);

[msg x y z] = xyzvcheck(x,y,z,data);  error(msg)


sz = size(data);
if isempty(x)
  [x y z] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3));
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

if isempty(verts)
  n = [];
else
  hx = x(1,:,1); 
  hy = y(:,1,1); 
  hz = z(1,1,:); 
  [nx ny nz] = gradient(data, hx, hy, hz);
  
  n(:,1)=interp3(x, y, z, nx, verts(:,1), verts(:,2), verts(:,3));
  n(:,2)=interp3(x, y, z, ny, verts(:,1), verts(:,2), verts(:,3));
  n(:,3)=interp3(x, y, z, nz, verts(:,1), verts(:,2), verts(:,3));
end

% The default needs to negate the normals so that isosurfaces
% drawn in opengl with backfacelighting==reverselit will be lit
% (keep the normals consistent with the handedness)
if ~negate
  n = -n;
end

if nargout==0 
  if ~isempty(p)
    set(p, 'vertexnormals', n)
  else
    nout = n;
  end
else
  nout = n;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, data, verts, negate] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
data = [];
verts = [];
negate = 0;

if nin>0
  lastarg = vargin{nin};
  if isstr(lastarg)
    if lower(lastarg(1))=='n' % negate
      negate = 1;
    end
    nin = nin - 1;
  end
end

if nin==2      % isonormals(v, verts)
  data = vargin{1};
  verts = vargin{2};
elseif nin==5  % isonormals(x,y,z,v, verts)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  verts = vargin{5};
else
  error('Wrong number of input arguments.'); 
end

