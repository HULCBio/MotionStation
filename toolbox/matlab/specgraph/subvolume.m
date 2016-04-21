function [newx, newy, newz, newdata, newv, neww] = subvolume(varargin)
%SUBVOLUME  Extract subset of volume dataset.
%   [NX, NY, NZ, NV] = SUBVOLUME(X,Y,Z,V,LIMITS) extracts a subset of
%   volume dataset V using specified axis-aligned LIMITS. LIMITS = 
%   [xmin xmax ymin ymax zmin zmax] (Any nans in the limits indicate 
%   that the volume should not be cropped along that axis.) Arrays X, 
%   Y and Z specify the points at which the data V is given. The 
%   subvolume is returned in NV and the coordinates of the subvolume 
%   are given in NX, NY and NZ.
%
%   [NX, NY, NZ, NV] = SUBVOLUME(V,LIMITS) assumes  
%               [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(V).
%   
%   [NX, NY, NZ, NU, NV, NW] = SUBVOLUME(X,Y,Z,U,V,W,LIMITS)
%   extracts subset of vector dataset U,V,W.
%
%   [NX, NY, NZ, NU, NV, NW] = SUBVOLUME(U,V,W,LIMITS) assumes  
%               [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U).
%   
%   NV = SUBVOLUME(...) or [NU, NV, NW] = SUBVOLUME(...) returns
%   the subvolume only. 
%
%   Example 1:
%      load mri
%      D = squeeze(D);
%      [x y z D] = subvolume(D, [60 80 nan 80 nan nan]);
%      p = patch(isosurface(x,y,z,D, 5), 'FaceColor', 'red', 'EdgeColor', 'none');
%      p2 = patch(isocaps(x,y,z,D, 5), 'FaceColor', 'interp', 'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(x,y,z,D,p);
%
%   Example 2:
%      load wind
%      [x y z u v w] = subvolume(x,y,z,u,v,w,[105 120  nan 30  2 6]);
%      streamslice(x,y,z,u,v,w,[],[],[3 4 5], .4);
%      daspect([1 1 .125])
%      h = streamtube(x,y,z,u,v,w,110,22,5.5);
%      set(h, 'FaceColor', 'red', 'EdgeColor', 'none')
%      axis tight
%      view(3)
%      camlight; lighting gouraud
%
%   See also ISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, REDUCEVOLUME,
%            REDUCEPATCH.
%

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/06/17 13:39:11 $

[x y z data u v w limits] = parseargs(nargin,varargin);

if prod(size(limits))~=6 
  error('Reduction must be [xmin xmax ymin ymax zmin zmax]');
end

if limits(1) > limits(2)
  error('In reduction vector, xmax must be greater than or equal to xmin');
end
if limits(3) > limits(4)
  error('In reduction vector, ymax must be greater than or equal to ymin');
end
if limits(5) > limits(6)
  error('In reduction vector, zmax must be greater than or equal to zmin');
end

if isempty(u)
  [msg x y z] = xyzvcheck(x,y,z,data);  error(msg)
  sz = size(data);
else
  [msg x y z] = xyzuvwcheck(x,y,z,u,v,w);  error(msg)
  sz = size(u);
end

if isempty(x)
  hx=1:sz(2);
  hy=1:sz(1);
  hz=1:sz(3);
else
  hx = x(1,:,1); 
  hy = y(:,1,1); 
  hz = z(1,1,:); 
end


if isnan(limits(1)),  limits(1) = min(hx); end
if isnan(limits(3)),  limits(3) = min(hy); end
if isnan(limits(5)),  limits(5) = min(hz); end
if isnan(limits(2)),  limits(2) = max(hx); end
if isnan(limits(4)),  limits(4) = max(hy); end
if isnan(limits(6)),  limits(6) = max(hz); end


xind = find(limits(1)<=hx & hx<=limits(2));
yind = find(limits(3)<=hy & hy<=limits(4));
zind = find(limits(5)<=hz & hz<=limits(6));


if isempty(u)
  newdata = subdata(data, yind, xind, zind, sz);
else
  newu = subdata(u, yind, xind, zind, sz);
  newv = subdata(v, yind, xind, zind, sz);
  neww = subdata(w, yind, xind, zind, sz);
end

if nargout==4 |  nargout==6
  if ~isempty(x)
    newx = x(yind, xind, zind);
    newy = y(yind, xind, zind);
    newz = z(yind, xind, zind);
  else
    [newx newy newz] = meshgrid(xind, yind, zind);
  end
  if ~isempty(u)
    newdata = newu;
  end
else
  if isempty(u)
    newx = newdata;
  else
    newx = newu;
    newy = newv;
    newz = neww;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newdata = subdata(data, yind, xind, zind, sz)
newdata = data(yind, xind, zind,:);
newsz = size(newdata);
if length(sz)>3
  newdata = reshape(newdata, [newsz(1:3) sz(4:end)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, data, u, v, w, lims] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
data = [];
u = [];
v = [];
w = [];
lims = [];

if nin==2           % subvolume(v,lims)
  data = vargin{1};
  lims = vargin{2};
elseif nin==4       % subvolume(u,v,w,lims)
  u = vargin{1};
  v = vargin{2};
  w = vargin{3};
  lims = vargin{4};
elseif nin==5       % subvolume(x,y,z,v,lims)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  lims = vargin{5};
elseif nin==7       % subvolume(x,y,z,u,v,w,lims)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  u = vargin{4};
  v = vargin{5};
  w = vargin{6};
  lims = vargin{7};
else
  error('Wrong number of input arguments.'); 
end
