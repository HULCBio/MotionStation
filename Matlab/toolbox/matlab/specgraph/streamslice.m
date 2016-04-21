function [ret1, ret2] = streamslice(varargin)
%STREAMSLICE  Streamlines in slice planes.
%   STREAMSLICE(X,Y,Z,U,V,W,Sx,Sy,Sz) draws well spaced streamlines
%   (with direction arrows) from vector data U,V,W in axis aligned
%   x,y,z planes at the points in the vectors Sx,Sy,Sz. The arrays
%   X,Y,Z define the coordinates for U,V,W and must be monotonic
%   and 3D plaid (as if produced by MESHGRID).  V must be an
%   M-by-N-by-P volume array. It should not be assumed that the
%   flow is parallel to the slice plane; for example, in a
%   streamslice at a constant z, the z component of the vector
%   field, W, is ignored when calculating the streamlines for that
%   plane. Streamslices are useful for determining where to start
%   streamlines, streamtubes, and streamribbons.  It is usually
%   best to set the DataAspectRatio before calling STREAMSLICE.   
%
%   STREAMSLICE(U,V,W,Sx,Sy,Sz) assumes 
%       [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(V).
%
%   STREAMSLICE(X,Y,U,V)  draws well spaced streamlines (with
%   direction arrows) from vector data U,V. The arrays X,Y define
%   the coordinates for U,V and must be monotonic and 2-D plaid (as
%   if produced by MESHGRID).  
%
%   STREAMSLICE(U,V) assumes 
%       [X Y] = meshgrid(1:N, 1:M) where [M,N]=SIZE(V).
%
%   STREAMSLICE(..., DENSITY) modifies the automatic spacing of the
%   streamlines. DENSITY must be greater than 0. The default value
%   is 1; higher values will produce more streamlines on each
%   plane. For example, 2 will produce approximately twice as many
%   streamlines while 0.5 will produce approximately half as many.   
% 
%   STREAMSLICE(...,'arrows'), (the default) draws direction
%   arrows. STREAMSLICE(...,'noarrows') suppresses drawing the 
%   direction arrows.
%
%   STREAMSLICE(...,'method') specifies the interpolation method to
%   use. 'method' can be 'linear', 'cubic', or 'nearest'.  'linear'
%   is the default (see INTERP3).
%   
%   STREAMSLICE(AX,...) plots into AX instead of GCA.
%
%   H = STREAMSLICE(...) returns a vector of handles to LINE
%   objects. 
%
%   [VERTICES ARROWVERTICES] = STREAMSLICE(...) returns 2 cell
%   arrays of vertices for drawing the streamlines and the
%   arrows.  These can be passed to any streamline drawing function 
%   (streamline) to draw the plot.
%
%   Example 1:
%      load wind
%      daspect([1 1 1])
%      streamslice(x,y,z,u,v,w,[],[],[5]); 
%
%   Example 2:
%      load wind
%      daspect([1 1 1])
%      [verts averts] = streamslice(u,v,w,10,10,10); 
%      streamline([verts averts]);
%      spd = sqrt(u.*u + v.*v + w.*w);
%      hold on; slice(spd,10,10,10);
%      colormap(hot)
%      shading interp
%      view(30,50); axis(volumebounds(spd));
%      camlight; material([.5 1 0])
%
%   Example 3:
%      z = peaks;
%      surf(z); hold on
%      shading interp;
%      [c ch] = contour3(z,20); set(ch, 'edgecolor', 'b')
%      [u v] = gradient(z); 
%      h = streamslice(-u,-v);  % downhill 
%      set(h, 'color', 'k')
%      for i=1:length(h); 
%        zi = interp2(z,get(h(i), 'xdata'), get(h(i),'ydata'));
%        set(h(i),'zdata', zi);
%      end
%      view(30,50); axis tight
%
%   See also STREAMLINE, SLICE, CONTOURSLICE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2002/10/24 02:14:30 $

% not implemented:
%   The colors of the streamlines
%   indicate if the flow is in or out of the slice plane.

[cax,args,nargs] = axescheck(varargin{:});
[x y z u v w sx sy sz density arrows method] = parseargs(nargs,args);

% Take this out when other data types are handled
u = double(u);
v = double(v);
w = double(w);


if isempty(method)
  method = 'linear';
end

if isempty(density)
  density = 1;
else
  density = sqrt(density);
end

if isempty(arrows)
  arrows = 1;
end


vertsout = {};
avertsout = {};

if isempty(w)  % 2D
  
  [msg x y] = xyuvcheck(x,y,u,v);  error(msg)
  [ny,nx] = size(u);
  if isempty(x)
    [x y] = meshgrid(1:nx, 1:ny);
  end

  [cax,dar] = getAxesDar(cax);
  if isempty(dar)
    dx = max(x(:)) - min(x(:));
    dy = max(y(:)) - min(y(:));
    dar = [dx dy];
  end
  dar = dar/max(dar);
  
  x = x/dar(1);
  y = y/dar(2);
  u = u/dar(1);
  v = v/dar(2);
  
  [vertsout avertsout] = nicestreams(x,y,u,v,density,arrows,dar);
  
else           % 3D
  % For each plane in each axis, generate stream slices.
  [msg x y z] = xyzuvwcheck(x,y,z,u,v,w);  error(msg)
  
  [ny,nx,nz] = size(u);
  if isempty(x)
    [x y z] = meshgrid(1:nx, 1:ny, 1:nz);
  end

  [cax,dar] = getAxesDar(cax);
  if isempty(dar)
    dx = max(x(:)) - min(x(:));
    dy = max(y(:)) - min(y(:));
    dz = max(z(:)) - min(z(:));
    dar = [dx dy dz];
  end
  dar = dar/max(dar);
  
  x = x/dar(1);
  y = y/dar(2);
  z = z/dar(3);
  u = u/dar(1);
  v = v/dar(2);
  w = w/dar(3);
  sx = sx/dar(1);
  sy = sy/dar(2);
  sz = sz/dar(3);

  % X axis
  [xi,yi,zi] = meshgrid(sx,y(:,1,1),z(1,1,:));
  vi = interp3(x,y,z,v,xi,yi,zi,method);
  wi = interp3(x,y,z,w,xi,yi,zi,method);
  
  for j = 1:length(sx)
    if ~( any(isnan(wi(:,j,:))) | any(isnan(vi(:,j,:))) )
      [verts averts] = nicestreams(...
	  reshape(zi(:,j,:),[ny nz]),...
	  reshape(yi(:,j,:),[ny nz]),...
	  reshape(wi(:,j,:),[ny nz]),...
	  reshape(vi(:,j,:),[ny nz]),density,arrows,dar([3 2]));
      for k = 1:length(verts)
	vv = verts{k};
	if ~isempty(vv)
	  verts{k} = [vv(:,1)*0+sx(j) vv(:,2) vv(:,1)];
	end
      end
      for k = 1:length(averts)
	vv = averts{k};
	if ~isempty(vv)
	  averts{k} = [vv(:,1)*0+sx(j) vv(:,2) vv(:,1)];
	end
      end
      vertsout = [vertsout verts];
      avertsout = [avertsout averts];
    end
  end
  
  
  % Y axis
  [xi,yi,zi] = meshgrid(x(1,:,1),sy,z(1,1,:));
  ui = interp3(x,y,z,u,xi,yi,zi,method);
  wi = interp3(x,y,z,w,xi,yi,zi,method);
  
  for j = 1:length(sy)
    if ~( any(isnan(wi(j,:,:))) | any(isnan(ui(j,:,:))) )
      [verts averts] = nicestreams(...
	  reshape(zi(j,:,:),[nx nz]),...
	  reshape(xi(j,:,:),[nx nz]),...
	  reshape(wi(j,:,:),[nx nz]),...
	  reshape(ui(j,:,:),[nx nz]),density,arrows,dar([3 1]));
      for k = 1:length(verts)
	vv = verts{k};
	if ~isempty(vv)
	  verts{k} = [vv(:,2) vv(:,1)*0+sy(j) vv(:,1)];
	end
      end
      for k = 1:length(averts)
	vv = averts{k};
	if ~isempty(vv)
	  averts{k} = [vv(:,2) vv(:,1)*0+sy(j) vv(:,1)];
	end
      end
      vertsout = [vertsout verts];
      avertsout = [avertsout averts];
    end
  end
    
  
  % Z axis
  [xi,yi,zi] = meshgrid(x(1,:,1),y(:,1,1),sz);
  ui = interp3(x,y,z,u,xi,yi,zi,method);
  vi = interp3(x,y,z,v,xi,yi,zi,method);
  
  for j = 1:length(sz)
    if ~( any(isnan(ui(:,:,j))) | any(isnan(vi(:,:,j))) )
      [verts averts] = nicestreams(xi(:,:,j),yi(:,:,j),ui(:,:,j),vi(:,:,j),density,arrows,dar([1 2]));
      for k = 1:length(verts)
	vv = verts{k};
	if ~isempty(vv)
	  verts{k} = [vv(:,1)  vv(:,2) vv(:,1)*0+sz(j)];
	end
      end
      for k = 1:length(averts)
	vv = averts{k};
	if ~isempty(vv)
	  averts{k} = [vv(:,1)  vv(:,2) vv(:,1)*0+sz(j)];
	end
      end
      vertsout = [vertsout verts];
      avertsout = [avertsout averts];
    end
  end
  
end

vertsout = scaleVerts(vertsout,dar);
avertsout = scaleVerts(avertsout,dar);
  

if nargout >= 2
  ret1 = vertsout; 
  ret2 = avertsout;
else
  h = streamline(cax,[vertsout avertsout]);
  if nargout==1
    ret1 = h;
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vertsout, avertsout] = nicestreams(x,y,u,v,density,arrows, dar);

stepsize = min(.1, (min(size(v))-1)/100);
streamoptions = [stepsize min(10000,sum(size(v))*2/stepsize)];

vertsout = {};
avertsout = {};

num = 20;
 
% grid spacing is dar aware
dar = dar/max(dar);
nrstart = ceil(num*density*dar(1));
ncstart = ceil(num*density*dar(2));
nrend   = ceil(num*density*4*dar(1));
ncend   = ceil(num*density*4*dar(2));
nrarrow = ceil(num*density*dar(1));
ncarrow = ceil(num*density*dar(2));

xmin = min(x(:));
xmax = max(x(:));
ymin = min(y(:));
ymax = max(y(:));
xrange = xmax-xmin;
yrange = ymax-ymin;

incstartx = xrange/ncstart;
inrstarty = yrange/nrstart;
ixrangecs = ncstart/xrange*(1-eps);
iyrangers = nrstart/yrange*(1-eps);
ixrangece = ncend/xrange*(1-eps);
iyrangere = nrend/yrange*(1-eps);

startgrid = zeros(nrstart,ncend);
endgrid = zeros(nrend,ncend);
if arrows
  arrowgrid = ones(nrarrow,ncarrow);
  arrowgrid(2:3:end,2:3:end) = 0;
  arrowscale = .01*(xrange+yrange)/density;
  ixrangeca = ncarrow/xrange*(1-eps);
  iyrangera = nrarrow/yrange*(1-eps);
end

[r c] = meshgrid(1:nrstart, 1:ncstart);
rc = [r(:) c(:)];
%rc = rc(randperm(size(rc,1)),:);

for k = 1:size(rc,1)
  %if mod(k,100)==0, disp([num2str(k) '/' num2str(size(rc,1))]), end
  r = rc(k,1);
  c = rc(k,2);
  if startgrid(r,c)==0

    startgrid(r,c)=1;
    
    xstart = xmin+(c-.5)*incstartx;
    ystart = ymin+(r-.5)*inrstarty;
    vertsf = stream2(x,y, u, v,xstart,ystart,streamoptions);
    vertsb = stream2(x,y,-u,-v,xstart,ystart,streamoptions);
    verts = {vertsf{:} vertsb{:}};
    for q = 1:2
      vv = verts{q};
      
      nanpos = find(isnan(vv));
      if ~isempty(nanpos)
	if nanpos(1)==1
	  vv = [];
	else
	  vv = vv(1:nanpos(1)-1,:);
	end
      end
 
      if ~isempty(vv)
	tcc = floor( (vv(1,1)-xmin)*ixrangece )+1;
	trr = floor( (vv(1,2)-ymin)*iyrangere )+1;
      end
      
      for j=1:size(vv,1)
	xc = vv(j,1);
	yc = vv(j,2);
	cc = floor( (xc-xmin)*ixrangecs )+1;
	rr = floor( (yc-ymin)*iyrangers )+1;
	startgrid(rr,cc)=1;
	
	cc = floor( (xc-xmin)*ixrangece )+1;
	rr = floor( (yc-ymin)*iyrangere )+1;
	if endgrid(rr,cc)==1
	  if ~(cc==tcc & rr==trr)
	    break;
	  end
	else
	  tcc=cc; trr=rr;
	  endgrid(rr,cc)=1;
	end
	if arrows
	  cc = floor( (xc-xmin)*ixrangeca )+1;
	  rr = floor( (yc-ymin)*iyrangera )+1;
	  if j>1 & arrowgrid(rr,cc)==0
	    arrowgrid(rr,cc)=1;
	    d = vv(j,:)-vv(j-1,:);
	    d = d/norm(d);
	    if q==2, d = -d; end;
	    
	    arrowlen = 1;
	    arrowwidth = .6;
	    p2 = [xc yc] - arrowlen*d .* arrowscale;
	    
	    av(1,:) = p2 - arrowwidth*[-d(2) d(1)].*arrowscale;
	    av(2,:) = [xc yc];
	    av(3,:) = p2 + arrowwidth*[-d(2) d(1)].*arrowscale;
	    
	    avertsout{end+1} = av;
	  end
	end
      end
      vo{q} = vv(1:j-1,:);
      
    end
    vertsout{end+1} = [flipud(vo{2}); vo{1}(2:end,:)];
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cax,dar] = getAxesDar(cax)
dar = [];
if isempty(cax)
    f = get(0, 'currentfigure');
    if ~isempty(f)
        cax = get(f, 'currentaxes');
    end
end

if isempty(cax)
    cax = newplot;
end

if strcmp(get(cax, 'dataaspectratiomode'), 'manual')
    dar = get(cax, 'dataaspectratio');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = scaleVerts(verts,dar)
ret = verts;
for k = 1:length(verts)
  vv = ret{k};
  for j = 1:size(vv,2)
   vv(:,j) = vv(:,j)*dar(j);
  end
  ret{k} = vv;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w, sx, sy, sz, density, arrows, method] = parseargs(nin, vargin)

[x, y, z, u, v, w, sx, sy, sz, density, arrows, method] = deal([]);

for j=1:2
  if nin>0
    lastarg = vargin{nin};
    if isstr(lastarg) % streamslice(...,'method'),  streamslice(...,'noarrows')
      if ~isempty(lastarg)
	lastarg = lower(lastarg);
	if lastarg(1)=='n' & length(lastarg)>=2 & lastarg(2)=='o'
	  arrows = 0;
	elseif lastarg(1)=='a' & length(lastarg)>=2 & lastarg(2)=='r'
	  arrows = 1;
	else
	  method = lastarg;
	end
      end
      nin = nin - 1;
    end
  end
end

if nin==2 | nin==3       % streamslice(u,v) or streamslice(u,v,density)
  u = vargin{1};
  v = vargin{2};
  if nin==3, density = vargin{3}; end
elseif nin==4 | nin==5   % streamslice(x,y,u,v) or streamslice(x,y,u,v,density)
  [x, y, u, v] = deal(vargin{1:4});
  if nin==5, density = vargin{5}; end
elseif nin==6 | nin==7   % streamslice(u,v,w,sx,sy,sz) or streamslice(u,v,w,sx,sy,sz,density) 
  [u, v, w, sx, sy, sz] = deal(vargin{1:6});
  if nin==7, density = vargin{7}; end
elseif nin==9 | nin==10   % streamslice(x,y,z,u,v,w,sx,sy,sz) or streamslice(x,y,z,u,v,w,sx,sy,sz,density)
  [x, y, z, u, v, w, sx, sy, sz] = deal(vargin{1:9});
  if nin==10, density = vargin{10}; end
else
  error('Wrong number of input arguments.'); 
end

sx = sx(:); 
sy = sy(:); 
sz = sz(:); 
