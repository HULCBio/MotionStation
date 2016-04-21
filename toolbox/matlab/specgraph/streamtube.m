function hout=streamtube(varargin)
%STREAMTUBE  3D stream tube.
%   STREAMTUBE(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) draws stream
%   tubes from vector data U,V,W. The arrays X,Y,Z define the
%   coordinates for U,V,W and must be monotonic and 3D plaid (as if
%   produced by MESHGRID). STARTX, STARTY, and STARTZ define the
%   starting positions of the streamlines at the center of the
%   tubes.  The width of the tubes is proportional to the
%   normalized divergence of the vector field. A vector of surface
%   handles (one per start point) is returned in H.  It is usually
%   best to set the DataAspectRatio before calling STREAMTUBE.   
%   
%   STREAMTUBE(U,V,W,STARTX,STARTY,STARTZ) assumes 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U). 
%   
%   STREAMTUBE(VERTICES,X,Y,Z,DIVERGENCE) assumes precomputed
%   streamline vertices and divergence. VERTICES is cell array of
%   streamline vertices (as if produced by stream3). X,Y,Z, and
%   DIVERGENCE are 3D arrays 
%
%   STREAMTUBE(VERTICES,DIVERGENCE)  assumes 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) where
%   [M,N,P] = SIZE(DIVERGENCE).   
%
%   STREAMTUBE(VERTICES,WIDTH) uses the cell array of vectors
%   WIDTH for the width of the tubes. The size of each
%   corresponding element of VERTICES and WIDTH must be equal.
%
%   STREAMTUBE(VERTICES,WIDTH) uses the scalar WIDTH for the
%   width of all streamtubes.
%
%   STREAMTUBE(VERTICES) automatically selects width.
%
%   STREAMTUBE(...,[SCALE N]) scales width of the tube by SCALE. 
%   The default is SCALE=1. When the streamtubes are created using
%   start points or divergence, SCALE=0 will suppress automatic
%   scaling. N is the number of points along the circumference of
%   the tube. The default is N=20.  
%
%   STREAMTUBE(AX,...) plots into AX instead of GCA.
%
%   H = STREAMTUBE(...)  returns a vector of handles (one per start
%   point) to SURFACE objects.
%
%   Example 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      h=streamtube(x,y,z,u,v,w,sx,sy,sz);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
%   Example 2:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      div = divergence(x,y,z,u,v,w);
%      daspect([1 1 1])
%      h=streamtube(verts,x,y,z,div);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
%   See also DIVERGENCE, STREAMRIBBON, STREAMLINE, STREAM3.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/10 23:32:25 $


[cax,args,nargs] = axescheck(varargin{:});
[x, y, z, u, v, w, sx, sy, sz, verts, div, width, scale, n] = ...
    parseargs(nargs,args);

if any(isnan(u(:))) |  any(isnan(v(:))) |  any(isnan(w(:)))
  error('Vector data U,V,W must not contain any NaNs')
end

if isempty(n),     n=20;    end
if isempty(scale), scale=1; end

% Calculate the vertices
if isempty(verts)
  [msg x y z] = xyzuvwcheck(x,y,z,u,v,w);  error(msg)
  verts = stream3(x,y,z,u,v,w,sx,sy,sz);
end


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

if isempty(dar)
  vv = cat(1,verts{:});
  if isempty(vv)
    dar = [1 1 1];
  else
    dar = max(vv,[],1) - min(vv,[],1);
    dar(dar==0) = 1;
  end
end

dar = dar/max(dar);

% Calculate and scale the widths from the divergence
if isempty(width)
  if ~isempty(u) & isempty(div)
    div = divergence(x,y,z,u,v,w);
  end
  for k = 1:length(verts)
    vv = verts{k};
    if ~isempty(vv)
      if ~isempty(div)
	if ~isempty(x)
	  divi{k} = interp3(x,y,z,div,vv(:,1), vv(:,2), vv(:,3));
	else
	  divi{k} = interp3(div,vv(:,1), vv(:,2), vv(:,3));
	end
      end
      vertminmax(k,:) = [min(vv,[],1) max(vv,[],1)];
    else
      divi{k} = [];
      vertminmax(k,:) = [nan nan nan nan nan nan];
    end
  end
  
  vertmin = min(vertminmax(:,1:3),[],1);
  vertmax = max(vertminmax(:,4:6),[],1);
  maxwidth = .05*max((vertmax-vertmin)./dar);
  if ~isempty(div)
    for k = 1:length(divi)
      if scale==0
	width{k} = divi{k};
      else
	divrange = max(divi{k})-min(divi{k});
	if divrange>0
	  width{k} = (divi{k}-min(divi{k}))/divrange *maxwidth*scale;
	else
	  width{k} = maxwidth*scale;
	end
      end
    end
  else
    width = maxwidth*scale; 
  end
  
else
  if iscell(width)
    for k = 1:length(width)
      width{k} = width{k}*scale;
    end
  else
    width = width*scale;
  end
end


h = [];
for k = 1:length(verts)
  vv = verts{k};
  if ~isempty(vv) & size(vv,1)>1
    if iscell(width)
      [xv yv zv] = tubecoords(vv,width{k},n,dar);
    else
      [xv yv zv] = tubecoords(vv,width,n,dar);
    end
    h = [h; surface(xv,yv,zv,'parent',cax)];
  end
end

if nargout>0 
  hout = h;
end

% Register handles with m-code generator
if ~isempty(h)
   mcoderegister('Handles',h,'Target',h(1),'Name','streamtube');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y,z]=tubecoords(verts,width,n,dar)

verts(:,1) = verts(:,1)/dar(1);
verts(:,2) = verts(:,2)/dar(2);
verts(:,3) = verts(:,3)/dar(3);

d1 = diff(verts);
zindex = find(~any(d1,2));
verts(zindex,:) = [];

if size(verts,1)<2
  x = []; y = []; , z = [];
  return;
end
		
d1 = diff(verts);

numverts = size(verts,1);
unitnormals = zeros(numverts,3);

% Radius of the tube.
if length(width)==1
  width = repmat(width, [numverts,1]);
else
  width(zindex) = [];
end
R = width/2;

d1(end+1,:) = d1(end,:);

x10 = verts(:,1)';
x20 = verts(:,2)';
x30 = verts(:,3)';
x11 = d1(:,1)';
x21 = d1(:,2)';
x31 = d1(:,3)';

a = verts(2,:) - verts(1,:);
b = [0 0 1];
c = crossSimple(a,b);
if ~any(c)
  b = [1 0 0];
  c = crossSimple(a,b);
end
b = crossSimple(c,a);
normb = norm(b); if normb~=0, b = b/norm(b); end
%b = b*R(1);

unitnormals(1,:) = b;

for j = 1:numverts-1;

  a = verts(j+1,:)-verts(j,:);
  c = crossSimple(a,b);
  b = crossSimple(c,a);
  normb = norm(b); if normb~=0, b = b/norm(b); end
%  b = b*R(j);
  unitnormals(j+1,:) = b;

end

unitnormal1 = unitnormals(:,1)';
unitnormal2 = unitnormals(:,2)';
unitnormal3 = unitnormals(:,3)';

speed = sqrt(x11.^2 + x21.^2 + x31.^2);

% And the binormal vector ( B = T x N )
binormal1 = (x21.*unitnormal3 - x31.*unitnormal2) ./ speed;
binormal2 = (x31.*unitnormal1 - x11.*unitnormal3) ./ speed;
binormal3 = (x11.*unitnormal2 - x21.*unitnormal1) ./ speed;

% s is the coordinate along the circular cross-sections of the tube:
s = (0:n)';
s = (2*pi/n)*s;

% Finally, the parametric surface.  
% Each of x1, x2, x3 is an (m+1)x(n+1) matrix.
% Rows represent coordinates along the tube.  Columns represent coordinates
% sgcfin each (circular) cross-section of the tube.

xa1 = ones(n+1,1)*x10;
xb1 = (cos(s)*unitnormal1 + sin(s)*binormal1);
xa2 = ones(n+1,1)*x20;
xb2 = (cos(s)*unitnormal2 + sin(s)*binormal2);
xa3 = ones(n+1,1)*x30;
xb3 = (cos(s)*unitnormal3 + sin(s)*binormal3);

R = repmat(R(:)',[n+1,1]);
x1 = xa1 + R.*xb1;
x2 = xa2 + R.*xb2;
x3 = xa3 + R.*xb3;
%x1 = xa1 + xb1;
%x2 = xa2 + xb2;
%x3 = xa3 + xb3;

x = x1' *dar(1);
y = x2' *dar(2);
z = x3' *dar(3);

%nx = unitnormal1;
%ny = unitnormal2;
%nz = unitnormal3;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simple cross product
function c=crossSimple(a,b)
c(1) = b(3)*a(2) - b(2)*a(3);
c(2) = b(1)*a(3) - b(3)*a(1);
c(3) = b(2)*a(1) - b(1)*a(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w, sx, sy, sz, verts, div, width, scale, n] = parseargs(nin, vargin)

[x, y, z, u, v, w, sx, sy, sz, verts, div, width, scale, n] = deal([]);

if (nin==6 | nin==7) & ~iscell(vargin{1})
                           % streamtube(u,v,w,sx,sy,sz) or streamtube(u,v,w,sx,sy,sz,scale)
  [u, v, w, sx, sy, sz] = deal(vargin{1:6});
  if nin==7, scale = vargin{7}; end
elseif nin==9 | nin==10    % streamtube(x,y,z,u,v,w,sx,sy,sz) or streamtube(x,y,z,u,v,w,sx,sy,sz,scale)
  [x, y, z, u, v, w, sx, sy, sz] = deal(vargin{1:9});
  if nin==10, scale = vargin{10}; end
elseif (nin==2 | nin==3 ) & ...
	    (length(size(vargin{2}))==3 | ...
	    iscell(vargin{2}) | ...
	    prod(size(vargin{2}))==1)
                         % streamtube(verts,divergence) or streamtube(verts,divergence,scale)
                         % streamtube(verts,width) or streamtube(verts,width,scale)
  verts = vargin{1};
  if length(size(vargin{2}))==3
    div = vargin{2};
  else
    width = vargin{2};
  end    
  if nin==3, scale = vargin{3}; end
elseif nin==5 | nin==6    % streamtube(verts,x,y,z,divergence) or streamtube(verts,x,y,z,divergence,scale)
  [verts, x, y, z, div] = deal(vargin{1:5});
  if nin==6, scale = vargin{6}; end
elseif nin==1 | nin==2    % streamtube(verts)  or streamtube(verts,scale) 
  verts = vargin{1};
  if nin==2, scale = vargin{2}; end
else
  error('Wrong number of input arguments.'); 
end

if ~isempty(sx)
  sx = sx(:); 
  sy = sy(:); 
  sz = sz(:); 
end

if ~isempty(scale)
  if length(scale) == 2
    n = scale(2);
    scale = scale(1);
  else
    error('[SCALE N] must be a 2 element vector.'); 
  end
end
