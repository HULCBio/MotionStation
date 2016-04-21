function [newx, newy, newz, newdata] = reducevolume(varargin)
%REDUCEVOLUME  Reduce volume dataset.
%   [NX, NY, NZ, NV] = REDUCEVOLUME(X,Y,Z,V,[Rx Ry Rz]) reduces the number
%   of elements in the volume by only keeping every Rx element in the x
%   direction, every Ry element in the y direction, and every Rz element
%   in the z direction. If a scalar R is used to indicate the amount or
%   reduction instead of a 3 element vector, the reduction is assumed to
%   be [R R R]. Arrays X, Y and Z specify the points at which the data V
%   is given. The reduced volume is returned in NV and the coordinates of
%   the reduced volume are given in NX, NY, and NZ.
%   
%   [NX, NY, NZ, NV] = REDUCEVOLUME(V,[Rx Ry Rz]) assumes  
%                   [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(V).
%
%   NV = REDUCEVOLUME(...) returns the reduced volume only.
%
%   Example:
%      load mri
%      D = squeeze(D);
%      [x y z D] = reducevolume(D, [4 4 1]);
%      D = smooth3(D);
%      p = patch(isosurface(x,y,z,D, 5,'verbose'), ...
%                'FaceColor', 'red', 'EdgeColor', 'none');
%      p2 = patch(isocaps(x,y,z,D, 5), 'FaceColor', 'interp', 'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(x,y,z,D,p);
%
%   See also ISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, SUBVOLUME,
%            REDUCEPATCH.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:39:06 $

[x y z data r] = parseargs(nargin,varargin);

[msg x y z] = xyzvcheck(x,y,z,data);  error(msg)


if length(r)==1
  r = [r r r];
end

if prod(size(r))~=3 
  error('Reduction must be [Rx Ry Rz] or R');
end

if ~isequal(r, floor(r)) | min(r)<1
  error('Reduction values must be integers greater than or equal to 2');
end

rx = r(1);
ry = r(2);
rz = r(3);

sz = size(data);
newdata = data(1:ry:end, 1:rx:end, 1:rz:end, :);
newsz = size(newdata);
if length(newsz)<3 | min(newsz)<2
  error('Reduction too high. Try a smaller reduction.');
end
if length(sz)>3
  newdata = reshape(newdata, [newsz(1:3) sz(4:end)]);
end


if nargout==4
  if ~isempty(x)
    newx = x(1:ry:end, 1:rx:end, 1:rz:end);
    newy = y(1:ry:end, 1:rx:end, 1:rz:end);
    newz = z(1:ry:end, 1:rx:end, 1:rz:end);
  else
    [newx newy newz] = meshgrid(1:rx:sz(2), 1:ry:sz(1), 1:rz:sz(3));
  end
else
  newx = newdata;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, data, r] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
data = [];
r = [];

if nin==2           % reducevolume(v,r)
  data = vargin{1};
  r = vargin{2};
elseif nin==5       % reducevolume(x,y,z,v,r)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  r = vargin{5};
else
  error('Wrong number of input arguments.'); 
end
