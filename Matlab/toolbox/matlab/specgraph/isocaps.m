function [retf, retv, retc] = isocaps(varargin)
%ISOCAPS  Isosurface end caps.
%   FVC = ISOCAPS(X,Y,Z,V,ISOVALUE) computes isosurface end cap geometry
%   for data V at isosurface value ISOVALUE. Arrays X, Y and Z specify the
%   points at which the data V is given. The struct FVC contains the
%   faces, vertices and colors of the end caps and can be passed directly
%   to the PATCH command.
%   
%   FVC = ISOCAPS(V,ISOVALUE) assumes [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
%         where [M,N,P]=SIZE(V). 
%   
%   FVC = ISOCAPS(X,Y,Z,V) or FVC = ISOCAPS(V) selects an isosurface
%        value automatically using the histogram of the data.
%   
%   FVC = ISOCAPS(..., ENCLOSE) ENCLOSE describes if the end caps
%   enclose data values above or below ISOVALUE. ENCLOSE can be 'above'
%   (default) or 'below'. 
%   
%   FVC = ISOPCAPS(..., WHICHPLANE) WHICHPLANE describes on which plane
%   or planes the end caps will be drawn.  WHICHPLANE is one of 'all'
%   (default), 'xmin', 'xmax', 'ymin', 'ymax', 'zmin', or 'zmax'.
%   
%   [F, V, C] = ISOCAPS(...) returns the faces, vertices and colors in
%               three arrays instead of a struct.
%   
%   ISOCAPS(...) With no output arguments, a patch is created with the
%   computed faces, vertices and colors.
%
%   Example:
%      load mri
%      D = squeeze(D);
%      D(:,1:60,:) = [];
%      p = patch(isosurface(D, 5), 'FaceColor', 'red', 'EdgeColor', 'none');
%      p2 = patch(isocaps(D, 5), 'FaceColor', 'interp', 'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(D, p);
%
%   See also ISOSURFACE, ISONORMALS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%            REDUCEPATCH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:39:01 $

[x y z data value enclose whichplane verbose] = parseargs(nargin,varargin);

if length(value)>1
  error('Isovalue must be a scalar.'); 
end

if isempty(value)
  value = isovalue(data);
end

% Take this out when other data types are handled
data = double(data);

[msg x y z] = xyzvcheck(x,y,z,data);  error(msg)


vmin = min([data(:); value]);
vmax = max([data(:); value]);
if enclose(1)=='b'
  pad = vmax+1;
else
  pad = vmin-1;
end

sz = size(data);
vv = [];

switch(whichplane)
case 'all'
  maxvert = 0; 
  ff = []; vv = []; cc = [];
  
  [f, v, c] = isocaps(data, value, enclose, 'xmin', verbose);
  ff = [ff; f+maxvert]; vv = [vv; v]; cc = [cc; c];
  maxvert = maxvert + size(v,1);

  [f, v, c] = isocaps(data, value, enclose, 'xmax', verbose);
  ff = [ff; f+maxvert]; vv = [vv; v]; cc = [cc; c];
  maxvert = maxvert + size(v,1);

  [f, v, c] = isocaps(data, value, enclose, 'ymin', verbose);
  ff = [ff; f+maxvert]; vv = [vv; v]; cc = [cc; c];
  maxvert = maxvert + size(v,1);

  [f, v, c] = isocaps(data, value, enclose, 'ymax', verbose);
  ff = [ff; f+maxvert]; vv = [vv; v]; cc = [cc; c];
  maxvert = maxvert + size(v,1);

  [f, v, c] = isocaps(data, value, enclose, 'zmin', verbose);
  ff = [ff; f+maxvert]; vv = [vv; v]; cc = [cc; c];
  maxvert = maxvert + size(v,1);

  [f, v, c] = isocaps(data, value, enclose, 'zmax', verbose);
  ff = [ff; f+maxvert]; vv = [vv; v]; cc = [cc; c];
  maxvert = maxvert + size(v,1);

case 'ymin'
  data2 = pad+zeros(2, sz(2), sz(3));
  data2(2,:,:) = data(1,:,:);
  [ff vv] = isosurface(data2, value, verbose);
  if ~isempty(vv)
    vv(:,2) = 1;
  end
case 'ymax'
  data2 = pad+zeros(2, sz(2), sz(3));
  data2(1,:,:) = data(end,:,:);
  [ff vv] = isosurface(data2, value, verbose);
  if ~isempty(vv)
    vv(:,2) = sz(1);
  end
case 'xmin'
  data2 = pad+zeros(sz(1), 2, sz(3));
  data2(:,2,:) = data(:,1,:);
  [ff vv] = isosurface(data2, value, verbose);
  if ~isempty(vv)
    vv(:,1) = 1;
  end
case 'xmax'
  data2 = pad+zeros(sz(1), 2, sz(3));
  data2(:,1,:) = data(:,end,:);
  [ff vv] = isosurface(data2, value, verbose);
  if ~isempty(vv)
    vv(:,1) = sz(2);
  end
case 'zmin'
  data2 = pad+zeros(sz(1), sz(2), 2);
  data2(:,:,2) = data(:,:,1);
  [ff vv] = isosurface(data2, value, verbose);
  if ~isempty(vv)
    vv(:,3) = 1;
  end
case 'zmax'
  data2 = pad+zeros(sz(1), sz(2), 2);
  data2(:,:,1) = data(:,:,end);
  [ff vv] = isosurface(data2, value, verbose);
  if ~isempty(vv)
    vv(:,3) = sz(3);
  end
otherwise
  error('WHICHPLANE can be: all, xmin, xmax, ymin, ymax, zmin, zmax.');
end    


if isempty(vv)
  vv = [];
  ff = [];
  cc = [];
else
  cc = interp3(data,vv(:,1), vv(:,2), vv(:,3));
  
  if ~isempty(x) 
    sz = size(x);
    if ~(isequal(x, 1:sz(2)) & isequal(y, 1:sz(1)) & isequal(z, 1:sz(3)))
      nv(:,1) = interp3( x, vv(:,1), vv(:,2), vv(:,3));
      nv(:,2) = interp3( y, vv(:,1), vv(:,2), vv(:,3));
      nv(:,3) = interp3( z, vv(:,1), vv(:,2), vv(:,3));
      vv = nv;
    end
  end
end


if nargout==0
  patch('faces', ff, 'vertices', vv, 'facevertexcdata', cc, ...
        'facecolor', 'interp', 'edgecolor', 'none')
elseif nargout==1
  retf.vertices = vv;
  retf.faces = ff;
  retf.facevertexcdata = cc;
else
  retf = ff;
  retv = vv;
  retc = cc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, data, value, enclose, whichplane, verbose] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
data = [];
value = [];
enclose = 'above';
whichplane = 'all';
verbose = '';

for j = 1:3
  if nin>0
    lastarg = vargin{nin};
    if isstr(lastarg) 
      if ~isempty(lastarg)
	lastarg = lower(lastarg);
	if strcmp(lastarg,'all') | lastarg(1)=='x' | lastarg(1)=='y' | lastarg(1)=='z' 
	  whichplane = lastarg;
	elseif lastarg(1)=='a'  | lastarg(1)=='b' % above/below
	  enclose = lastarg;
	end
	if lastarg(1)=='v' % verbose
	  verbose = lastarg;
	end
      end
      nin = nin - 1;
    end
  end
end

if nin==1 | nin==2       % isocaps(v, isoval), isocaps(v)
  data = vargin{1};
  if nin==2
    value = vargin{2};
  end
elseif nin==4 |nin==5   % isocaps(x,y,z,v, isoval), isocaps(x,y,z,v)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  if nin==5
    value = vargin{5};
  end
else
  error('Wrong number of input arguments.'); 
end

