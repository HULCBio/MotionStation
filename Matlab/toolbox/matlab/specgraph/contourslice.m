function hout = contourslice(varargin)
%CONTOURSLICE  Contours in slice planes.
%   CONTOURSLICE(X,Y,Z,V,Sx,Sy,Sz) draws contours in axis aligned x,y,z
%   planes at the points in the vectors Sx,Sy,Sz. The arrays X,Y,Z define
%   the coordinates for V and must be monotonic and 3-D plaid (as if
%   produced by MESHGRID).  The color at each contour will be determined
%   by the volume V.  V must be an M-by-N-by-P volume array.
%   
%   CONTOURSLICE(X,Y,Z,V,XI,YI,ZI) draws contours through the volume V  
%   along the surface defined by the arrays XI,YI,ZI.
%
%   CONTOURSLICE(V,Sx,Sy,Sz) or CONTOURSLICE(V,XI,YI,ZI) assumes 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(V).
%   
%   CONTOURSLICE(..., N) draw N contour lines per plane, overriding the
%   automatic value.
%   
%   CONTOURSLICE(..., CVALS) draws LENGTH(CVALS) contour lines per plane
%   at the values specified in vector CVALS.
%   
%   CONTOURSLICE(..., [cv cv]) computes a single contour per plane at the
%   level cv.
%   
%   CONTOURSLICE(...,'method') specifies the interpolation method to use.
%   'method' can be 'linear', 'cubic', or 'nearest'.  'nearest' is the
%   default except when the contours are being drawn along the
%   surface defined XI,YI,ZI when 'linear' is the default (see INTERP3).
%   
%   CONTOURSLICE(AX,...) plots into AX instead of GCA.
%
%   H = CONTOURSLICE(...) returns a vector of handles to PATCH
%   objects in H.
%
%   Example:
%     [x y z v] = flow;
%     h=contourslice(x,y,z,v,[1:9],[],[0], linspace(-8,2,10));
%     axis([0 10 -3 3 -3 3]); daspect([1 1 1])
%     camva(24); camproj perspective;
%     campos([-3 -15 5])
%     set(gcf, 'Color', [.3 .3 .3], 'renderer', 'zbuffer')
%     set(gca, 'Color', 'black' , 'XColor', 'white', ...
%              'YColor', 'white' , 'ZColor', 'white')
%     box on
%
%   See also ISOSURFACE, SMOOTH3, SUBVOLUME, REDUCEVOLUME.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2002/09/26 01:55:20 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

[x y z v sx sy sz cvals method] = parseargs(nargs,args);

[ny,nx,nz] = size(v);

if isnan(sx)
  if isempty(x)
    sx = 1:nx;
  else
    sx = linspace(min(x(:)), max(x(:)), nx);
  end
end
if isnan(sy)
  if isempty(y)
    sy = 1:ny;
  else
    sy = linspace(min(y(:)), max(y(:)), ny);
  end
end
if isnan(sz)
  if isempty(z)
    sz = 1:nz;
  else
    sz = linspace(min(z(:)), max(z(:)), nz);
  end
end

% Take this out when other data types are handled
v = double(v);

[msg x y z] = xyzvcheck(x,y,z,v);  error(msg)

if isempty(x)
  [x y z] = meshgrid(1:nx, 1:ny, 1:nz);
end

if min(size(sx))<=1 & min(size(sy))<=1 & min(size(sz))<=1
  axis_slice = 1; % Slice only along axes?
else
  axis_slice = 0; 
end

if isempty(method)
  if axis_slice
    method = 'nearest';
  else
    method = 'linear';
  end
end

h = [];

% Create plot
cax = newplot(cax);

if axis_slice,
  [xi,yi,zi] = meshgrid(sx,y(:,1,1),z(1,1,:));
  vi = interp3(x,y,z,v,xi,yi,zi,method);
  if ~all(isnan(vi))
    for i = 1:length(sx)
      if isempty(cvals)
	c=contours( ...
	    reshape(yi(:,i,:),[ny nz]), ...
	    reshape(zi(:,i,:),[ny nz]), ...
	    reshape(vi(:,i,:),[ny nz]));
      else
	c=contours( ...
	    reshape(yi(:,i,:),[ny nz]), ...
	    reshape(zi(:,i,:),[ny nz]), ...
	    reshape(vi(:,i,:),[ny nz]), ...
	    cvals);
      end
      
      limit = size(c,2);
      j = 1;
      while(j < limit)
	c_level = c(1,j);
	npoints = c(2,j);
	nextj = j+npoints+1;
	
	xdata = c(1,j+1:j+npoints);
	ydata = c(2,j+1:j+npoints);
	cdata = c_level + 0*xdata;  % Make cdata the same size as xdata
	sdata = sx(i)   + 0*xdata;  % Make sdata the same size as xdata
    
	% Create the patches or lines
	p = patch('XData',[sdata NaN],'YData',[xdata NaN], ...
	    'ZData',[ydata NaN],'CData',[cdata NaN], ... 
	    'facecolor','none','edgecolor','flat',...
	    'userdata',c_level,'parent',cax);
	h = [h; p(:)];
	j = nextj;
      end
    end
  end
  
  
  [xi,yi,zi] = meshgrid(x(1,:,1),sy,z(1,1,:));
  vi = interp3(x,y,z,v,xi,yi,zi,method);
  if ~all(isnan(vi))
    for i = 1:length(sy)
      if isempty(cvals)
	c=contours( ...
	    reshape(xi(i,:,:),[nx nz]), ...
	    reshape(zi(i,:,:),[nx nz]), ...
	    reshape(vi(i,:,:),[nx nz]));
      else
	c=contours( ...
	    reshape(xi(i,:,:),[nx nz]), ...
	    reshape(zi(i,:,:),[nx nz]), ...
	    reshape(vi(i,:,:),[nx nz]), ...
	    cvals);
      end
      
      limit = size(c,2);
      j = 1;
      while(j < limit)
	c_level = c(1,j);
	npoints = c(2,j);
	nextj = j+npoints+1;
	
	xdata = c(1,j+1:j+npoints);
	ydata = c(2,j+1:j+npoints);
	cdata = c_level + 0*xdata;  % Make cdata the same size as xdata
	sdata = sy(i)   + 0*xdata;  % Make sdata the same size as xdata
	
	% Create the patches or lines
	p = patch('XData',[xdata NaN],'YData',[sdata NaN], ...
	    'ZData',[ydata NaN],'CData',[cdata NaN], ... 
	    'facecolor','none','edgecolor','flat',...
	    'userdata',c_level,'parent',cax);
	h = [h; p(:)];
	j = nextj;
      end
    end
  end
  
  [xi,yi,zi] = meshgrid(x(1,:,1),y(:,1,1),sz);
  vi = interp3(x,y,z,v,xi,yi,zi,method);
  if ~all(isnan(vi))
    for i = 1:length(sz)
      if isempty(cvals)
	c=contours(xi(:,:,i),yi(:,:,i),vi(:,:,i));
      else
	c=contours(xi(:,:,i),yi(:,:,i),vi(:,:,i), cvals);
      end
      
      limit = size(c,2);
      j = 1;
      while(j < limit)
	c_level = c(1,j);
	npoints = c(2,j);
	nextj = j+npoints+1;
	
	xdata = c(1,j+1:j+npoints);
	ydata = c(2,j+1:j+npoints);
	cdata = c_level + 0*xdata;  % Make cdata the same size as xdata
	sdata = sz(i)   + 0*xdata;  % Make sdata the same size as xdata
	
	% Create the patches or lines
	p = patch('XData',[xdata NaN],'YData',[ydata NaN], ...
	    'ZData',[sdata NaN],'CData',[cdata NaN], ... 
	    'facecolor','none','edgecolor','flat',...
	    'userdata',c_level,'parent',cax);
	h = [h; p(:)];
	j = nextj;
      end
    end
  end
  
else
  vi = interp3(x,y,z,v,sx,sy,sz,'linear');
  %h = surf(sx,sy,sz,vi);
  if ~all(isnan(vi))
    if isempty(cvals)
      c=contourc(vi);
    else
      c=contourc(vi,cvals);
    end
    
    limit = size(c,2);
    j = 1;
    while(j < limit)
      c_level = c(1,j);
      npoints = c(2,j);
      nextj = j+npoints+1;
      
      xdata = c(1,j+1:j+npoints);
      ydata = c(2,j+1:j+npoints);
      
      xx = interp2(sx, xdata, ydata);
      yy = interp2(sy, xdata, ydata);
      zz = interp2(sz, xdata, ydata);
      cc = c_level + 0*xx;  % Make cdata the same size as xdata
      % Create the patches or lines
      p = patch('XData',[xx NaN],'YData',[yy NaN], ...
	  'ZData',[zz NaN],'CData',[cc NaN], ... 
	  'facecolor','none','edgecolor','flat',...
	  'userdata',c_level,'parent',cax);
      h = [h; p(:)];
      j = nextj;
    end
  end
end

if nargout > 0
  hout = h;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, data, sx, sy, sz, cvals, method] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
data = [];
sx = [];
sy = [];
sz = [];
cvals = [];
method = [];

if nin>0
  lastarg = vargin{nin};
  if isstr(lastarg) % contourslice(...,'method')
    method = lastarg;
    nin = nin - 1;
  end
end

if nin==4         % contourslice(v,sx,sy,sz)
  data = vargin{1};
  sx = vargin{2};
  sy = vargin{3};
  sz = vargin{4};
elseif nin==5     % contourslice(v,sx,sy,sz,cvals)
  data = vargin{1};
  sx = vargin{2};
  sy = vargin{3};
  sz = vargin{4};
  cvals = vargin{5};
elseif nin==7     % contourslice(x,y,z,v,sx,sy,sz)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  sx = vargin{5};
  sy = vargin{6};
  sz = vargin{7};
elseif nin==8     % contourslice(x,y,z,v,sx,sy,sz,cvals)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  sx = vargin{5};
  sy = vargin{6};
  sz = vargin{7};
  cvals = vargin{8};
else
  error('Wrong number of input arguments.'); 
end
