function hout=streamribbon(varargin)
%STREAMRIBBON  3D stream ribbon.
%   STREAMRIBBON(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) draws stream
%   ribbons from vector data U,V,W. The arrays X,Y,Z define the
%   coordinates for U,V,W and must be monotonic and 3D plaid (as if
%   produced by MESHGRID). STARTX, STARTY, and STARTZ define the
%   starting positions of the streamlines at the center of the
%   ribbons.  The twist of the ribbons is proportional to the
%   curl of the vector field. The width of the ribbons is
%   calculated  automatically. It is usually best to set the
%   DataAspectRatio before calling STREAMRIBBON. 
%   
%   STREAMRIBBON(U,V,W,STARTX,STARTY,STARTZ) assumes 
%      [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U). 
%   
%   STREAMRIBBON(VERTICES,X,Y,Z,CAV,SPEED) assumes precomputed 
%   streamline vertices, curl angular velocity, and flow
%   speed. VERTICES is cell array of streamline vertices (as if
%   produced by stream3). X,Y,Z, CAV and SPEED are 3D arrays.
%
%   STREAMRIBBON(VERTICES,CAV,SPEED)  assumes 
%      [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P] = SIZE(CAV).
%
%   STREAMRIBBON(VERTICES,TWISTANGLE) uses the cell array of
%   vectors TWISTANGLE for the twist of the ribbons (in
%   radians). The size of each corresponding element of VERTICES
%   and TWISTANGLE must be equal. 
%
%   STREAMRIBBON(...,WIDTH) sets the width of the ribbons to be
%   WIDTH. 
%
%   STREAMRIBBON(AX,...) plots into AX instead of GCA.  
%
%   H = STREAMRIBBON(...)  returns a vector of handles (one per
%   start point) to SURFACE objects.
%
%   Example 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      h=streamribbon(x,y,z,u,v,w,sx,sy,sz);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
%   Example 2:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      cav = curl(x,y,z,u,v,w);
%      spd = sqrt(u.^2 + v.^2 + w.^2);
%      h=streamribbon(verts,x,y,z,cav,spd);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
%   Example 3:
%      t = 0:.15:15;
%      verts = {[cos(t)' sin(t)' (t/3)']};
%      twistangle = {cos(t)'};
%      daspect([1 1 1])
%      h=streamribbon(verts,twistangle);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
%   Example 4:
%     xmin = -7; xmax = 7;
%     ymin = -7; ymax = 7; 
%     zmin = -7; zmax = 7; 
%     x = linspace(xmin,xmax,30);
%     y = linspace(ymin,ymax,20);
%     z = linspace(zmin,zmax,20);
%     [x y z] = meshgrid(x,y,z);
%     u = y; v = -x; w = 0*x+1;
%     
%     daspect([1 1 1]); 
%     [cx cy cz] = meshgrid(linspace(xmin,xmax,30),linspace(ymin,ymax,30),[-3 4]);
%     h2=coneplot(x,y,z,u,v,w,cx,cy,cz, 'q');
%     set(h2, 'color', 'k');
%     
%     [sx sy sz] = meshgrid([-1 0 1],[-1 0 1],-6);
%     p = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%     [sx sy sz] = meshgrid([1:6],[0],-6);
%     p2 = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%     shading interp
%     
%     view(-30,10) ; axis off tight
%     camproj p; camva(66); camlookat; camdolly(0,0,.5,'f')
%     camlight
%
%   See also CURL, STREAMTUBE, STREAMLINE, STREAM3.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2004/04/10 23:32:24 $

[cax,args,nargs] = axescheck(varargin{:});
[x, y, z, u, v, w, sx, sy, sz, verts, cav, spd, twistangle, width] = ...
    parseargs(nargs,args);

if any(isnan(u(:))) |  any(isnan(v(:))) |  any(isnan(w(:)))
  error('Vector data U,V,W must not contain any NaNs')
end
  
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

% Get the axes if none has been specified yet
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

% Calculate the twistangles
if isempty(twistangle)
  if isempty(cav)
    cav = curl(x,y,z,u,v,w);
    spd = sqrt(u.^2 + v.^2 + w.^2 );
  end
  
  for k = 1:length(verts)
    vv = verts{k};
    if ~isempty(vv)
      if ~isempty(x)
	cavi{k} = interp3(x,y,z,cav,vv(:,1), vv(:,2), vv(:,3));
	spdi{k} = interp3(x,y,z,spd,vv(:,1), vv(:,2), vv(:,3));
      else
	cavi{k} = interp3(cav,vv(:,1), vv(:,2), vv(:,3));
	spdi{k} = interp3(spd,vv(:,1), vv(:,2), vv(:,3));
      end
    end
  end

end

% Calculate a width if none was passed in.
if isempty(width)
  for k = 1:length(verts)
    vv = verts{k};
    if ~isempty(vv)
      vertminmax(k,:) = [min(vv,[],1) max(vv,[],1)];
    else
      vertminmax(k,:) = [nan nan nan nan nan nan];
    end
  end
  
  vertmin = min(vertminmax(:,1:3),[],1);
  vertmax = max(vertminmax(:,4:6),[],1);
  width = .05*max((vertmax-vertmin)./dar);
end    


h = [];
for k = 1:length(verts)
  vv = verts{k};
  if ~isempty(vv) & size(vv,1)>1
    if isempty(twistangle)
      %fvc = ribboncoords(vv,cavi{k},spdi{k},width);
      %h = [h; patch(fvc)];
      [xyzc] = ribboncoords(vv,cavi{k},spdi{k},width,dar);
      xyzc.Parent = cax;
      h = [h; surface(xyzc)];
    else
      %fvc = ribboncoords(vv,twistangle{k},width);
      %h = [h; patch(fvc)];
      [xyzc] = ribboncoords(vv,twistangle{k},width,dar);
      xyzc.Parent = cax;
      h = [h; surface(xyzc)];
    end
  end
end

if nargout>0 
  hout = h;
end

% Register handles with m-code generator
if ~isempty(h)
  mcoderegister('Handles',h,'Target',h(1),'Name','streamribbon');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=ribboncoords(verts,arg1,arg2,arg3,arg4)

if nargin==5
  cav = arg1;
  spd = arg2;
  twistangle = [];
  width = arg3;
  dar = arg4;
else
  cav = [];
  spd = [];
  twistangle = arg1;
  width = arg2;
  dar = arg3;
end

verts(:,1) = verts(:,1)/dar(1);
verts(:,2) = verts(:,2)/dar(2);
verts(:,3) = verts(:,3)/dar(3);

R = width/2;

numverts = size(verts,1);
srv = zeros(numverts*2,3);


a = verts(2,:) - verts(1,:);
b = [0 0 1];
c = crossSimple(a,b);
if ~any(c)
  b = [1 0 0];
  c = crossSimple(a,b);
end
b = crossSimple(c,a);
if ~isempty(twistangle)
  b = rotategeom(b, a,  twistangle(1));
end
normb = norm(b); if normb~=0, b = b/norm(b); end
b = b*R;

srv(1,:) = verts(1,:)+b;
srv(2,:) = verts(1,:)-b;


if isempty(twistangle)
  
  dis = sqrt(sum(diff(verts).^2,2)); %distance
  q = zeros(numverts,1); % the currenty angle
  spd = (spd(1:numverts-1)+spd(2:numverts))/2;
  cav = (cav(1:numverts-1)+cav(2:numverts))/2;
  for j = 1:numverts-1;
    t = dis(j)/spd(j);
    
    q(j+1) = q(j)+cav(j)*t;
    
    a = verts(j+1,:)-verts(j,:);
    nb = rotategeom(b, a,  q(j+1)-q(j));
    c = crossSimple(a,nb);
    b = crossSimple(c,a);
    normb = norm(b); if normb~=0, b = b/norm(b); end
    b = b*R;
    
    srv(2*j+1,:) = verts(j+1,:)+b;
    srv(2*j+2,:) = verts(j+1,:)-b;
  end
  
else
  
  q = cumsum(twistangle(:));
  for j = 1:numverts-1;
    a = verts(j+1,:)-verts(j,:);
    nb = rotategeom(b, a, twistangle(j+1));
    c = crossSimple(a,nb);
    b = crossSimple(c,a);
    normb = norm(b); if normb~=0, b = b/norm(b); end
    b = b*R;
    
    srv(2*j+1,:) = verts(j+1,:)+b;
    srv(2*j+2,:) = verts(j+1,:)-b;
  end
  
end

%fvc = [q';q'];
%f = (1:2:size(srv,1)-2)';
%f = [f f+1 f+3 f+2];

%ret.faces = f;
%ret.vertices = srv;
%ret.facevertexcdata = fvc(:);

ret.xdata = dar(1)*reshape(srv(:,1)',[2,numverts])';
ret.ydata = dar(2)*reshape(srv(:,2)',[2,numverts])';
ret.zdata = dar(3)*reshape(srv(:,3)',[2,numverts])';
ret.cdata = [q q];

  


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
function vout=rotategeom(v,azel,alpha)
nrmazel = norm(azel);
if nrmazel==0 | alpha==0
  vout = v;
else
  u = azel(:)/nrmazel;
  cosa = cos(alpha);
  sina = sin(alpha);
  vera = 1 - cosa;
  x = u(1);
  y = u(2);
  z = u(3);
  rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
	 x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
	 x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';
  
  x = v(:,1);
  y = v(:,2);
  z = v(:,3);
  
  [m,n] = size(x);
  newxyz = [x(:), y(:), z(:)];
  newxyz = newxyz*rot;
  newx = reshape(newxyz(:,1),m,n);
  newy = reshape(newxyz(:,2),m,n);
  newz = reshape(newxyz(:,3),m,n);
  
  vout = [newx newy newz];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w, sx, sy, sz, verts, cav, spd, twistangle, width] = parseargs(nin, vargin)

[x, y, z, u, v, w, sx, sy, sz, verts, cav, spd, twistangle, width] = deal([]);

if (nin==6 | nin==7) & ~iscell(vargin{1})
                           % streamribbon(u,v,w,sx,sy,sz) or streamribbon(u,v,w,sx,sy,sz,width)
  [u, v, w, sx, sy, sz] = deal(vargin{1:6});
  if nin==7, width = vargin{7}; end
elseif nin==9 | nin==10    % streamribbon(x,y,z,u,v,w,sx,sy,sz) or streamribbon(x,y,z,u,v,w,sx,sy,sz,width)
  [x, y, z, u, v, w, sx, sy, sz] = deal(vargin{1:9});
  if nin==10, width = vargin{10}; end
elseif (nin==2 | nin==3 | nin==4) 
                         % streamribbon(verts,cav,spd) or streamribbon(verts,cav,spd,width)
                         % streamribbon(verts,twistangle) or streamribbon(verts,twistangle,width)
  verts = vargin{1};
  if length(size(vargin{2}))==3
    cav = vargin{2};
    spd = vargin{3};
    if nin==4, width = vargin{4}; end
  else
    twistangle = vargin{2};
    if nin==3, width = vargin{3}; end
  end    
elseif nin==6 | nin==7    % streamribbon(verts,x,y,z,cav,spd) or streamribbon(verts,x,y,z,cav,spd,width)
  [verts, x, y, z, cav, spd] = deal(vargin{1:6});
  if nin==7, width = vargin{7}; end
else
  error('Wrong number of input arguments.'); 
end

if ~isempty(sx)
  sx = sx(:); 
  sy = sy(:); 
  sz = sz(:); 
end
