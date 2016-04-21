function vertsout = interpstreamspeed(varargin)
%INTERPSTREAMSPEED  Interpolate streamline vertices from speed.
%   INTERPSTREAMSPEED(X,Y,Z,U,V,W,VERTICES) interpolates streamline
%   vertices based on the speed of the vector data U,V,W.  The
%   arrays X,Y,Z define the coordinates for U,V,W and must be
%   monotonic and 3D plaid (as if produced by MESHGRID).   
%   
%   INTERPSTREAMSPEED(U,V,W,VERTICES) assumes 
%     [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U).
%   
%   INTERPSTREAMSPEED(X,Y,Z,SPEED,VERTICES) uses the 3D array SPEED
%   for the speed of the vector field.
%
%   INTERPSTREAMSPEED(SPEED,VERTICES) assumes 
%     [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(SPEED).
%   
%   INTERPSTREAMSPEED(X,Y,U,V,VERTICES) interpolates streamline
%   vertices based on the speed of the vector data U,V.  The arrays
%   X,Y define the coordinates for U,V and must be monotonic and 2D
%   plaid (as if produced by MESHGRID).   
%   
%   INTERPSTREAMSPEED(U,V,VERTICES) assumes 
%     [X Y] = meshgrid(1:N, 1:M) where [M,N]=SIZE(U).
%   
%   INTERPSTREAMSPEED(X,Y,SPEED,VERTICES) uses the 2D array SPEED
%   for the speed of the vector field. 
%
%   INTERPSTREAMSPEED(SPEED,VERTICES) assumes 
%     [X Y] = meshgrid(1:N, 1:M) where [M,N]=SIZE(SPEED).
%   
%   INTERPSTREAMSPEED(...SF) uses SF to scale the speed of the
%   vector data and therefore controls the number of interpolated
%   vertices. For example, if SF were 3, one third of the vertices
%   would be created.
%   
%   VERTSOUT = INTERPSTREAMSPEED(...) returns the cell array of
%   vertex arrays.
%   
%   Example 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:1:55, 5);
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      iverts = interpstreamspeed(x,y,z,u,v,w,verts,.2);
%      sl=streamline(iverts);
%      set(sl, 'marker', '.');
%      axis tight; view(2); daspect([1 1 1])
%
%   Example 2:
%      z = membrane(6,30);
%      [u v] = gradient(z);
%      [verts averts] = streamslice(u,v);
%      iverts = interpstreamspeed(u,v,verts,15);
%      sl=streamline(iverts);
%      set(sl, 'marker', '.');
%      hold on; surf(0*z-1,z); shading interp
%      axis tight; view(2); daspect([1 1 1])
%
%   See also STEAMPARTICLES, STREAMSLICE, STREAMLINE, STREAM3,
%            STREAM2. 

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/06/17 13:39:15 $


[x, y, z, u, v, w, verts, spd, sf] = parseargs(nargin,varargin);


if any(any(isnan(cat(1, verts{:}))))
  error('Stream vertices cannot contain NaNs')
end

if any(isnan(u(:))) |  any(isnan(v(:))) |  any(isnan(w(:))) 
  error('U,V,W cannot contain NaNs')
end

% Calculate speed if needed
if isempty(spd)
  if isempty(w)  % 2D
    spd = sqrt(u.^2 + v.^2);
  else        % 3D
    spd = sqrt(u.^2 + v.^2 + w.^2);
  end
end

if isempty(sf)
  sf = 1;
end

vertsout = repmat({[]},1,length(verts));
for i = 1:length(verts);
  vv = verts{i};

  % Interpolate speed onto vertices
  if size(vv,2)==3 % 3D
    if isempty(x)
      spdi = interp3(spd,vv(:,1), vv(:,2), vv(:,3));
    else
      spdi = interp3(x,y,z,spd,vv(:,1), vv(:,2), vv(:,3));
    end
  else    % 2D
    if isempty(x)
      spdi = interp2(spd,vv(:,1), vv(:,2));
    else
      spdi = interp2(x,y,spd,vv(:,1), vv(:,2));
    end
  end
  
  spdi = spdi*sf;
  
  % Remove coincident vertices
  d1 = diff(vv);
  zindex = find(~any(d1,2));
  vv(zindex,:) = [];

  if size(vv,1)==1
    vertsout{i}(end+1,:) = vv; 
  else
    % Calculate new vertex positions
    dis = [0 ; cumsum(sqrt(sum(diff(vv).^2,2)))];
    d = 0;
    pos = 1;
    while(pos<length(dis))
      frac = (d-dis(pos))/(dis(pos+1)-dis(pos));
      p =   vv(pos,:)*(1-frac) +   vv(pos+1,:)*frac;
      s = spdi(pos  )*(1-frac) + spdi(pos+1  )*frac;
      vertsout{i}(end+1,:) = p; 
      d = d+s;
      pos = find(dis<d);
      if ~isempty(pos), pos = pos(end); end
    end
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w, verts, spd, sf] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
u = [];
v = [];
w = [];
verts = [];
spd = [];
sf = [];


if (nin==5 | nin==6) & ndims(vargin{3})==2 & iscell(vargin{5}) 
  x = vargin{1}; % 2D interpstreamspeed(x,y,u,v,verts) or interpstreamspeed(x,y,u,v,verts,sf)
  y = vargin{2};
  u = vargin{3};
  v = vargin{4};
  verts = vargin{5};
  if nin==6, sf = vargin{6}; end
elseif (nin==3 | nin==4) & ndims(vargin{1})==2  & iscell(vargin{3}) 
  u = vargin{1}; % 2D interpstreamspeed(u,v,verts) or interpstreamspeed(u,v,verts,sf)
  v = vargin{2};
  verts = vargin{3};
  if nin==4, sf = vargin{4}; end
elseif (nin==4 | nin==5) & ndims(vargin{3})==2 & iscell(vargin{4}) 
  x = vargin{1}; % 2D interpstreamspeed(x,y,spd,verts) or interpstreamspeed(x,y,spd,verts,sf)
  y = vargin{2};
  spd = vargin{3};
  verts = vargin{4};
  if nin==5, sf = vargin{5}; end
elseif nin==7 | nin==8  % 3D interpstreamspeed(x,y,z,u,v,w,verts) or interpstreamspeed(x,y,z,u,v,w,verts,sf)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  u = vargin{4};
  v = vargin{5};
  w = vargin{6};
  verts = vargin{7};
  if nin==8, sf = vargin{8}; end
elseif (nin==4 | nin==5)  & iscell(vargin{4}) 
  u = vargin{1};      % 3D interpstreamspeed(u,v,w,verts) or interpstreamspeed(u,v,w,verts,sf)
  v = vargin{2};
  w = vargin{3};
  verts = vargin{4};
  if nin==5, sf = vargin{5}; end
elseif nin==5 | nin==6
  x = vargin{1};      % 3D interpstreamspeed(x,y,z,spd,verts) or interpstreamspeed(x,y,z,spd,verts,sf)
  y = vargin{2};
  z = vargin{3};
  spd = vargin{4};
  verts = vargin{5};
  if nin==6, sf = vargin{6}; end
elseif nin==2 | nin==3
  spd = vargin{1};      % interpstreamspeed(spd,verts) or interpstreamspeed(spd,verts,sf)
  verts = vargin{2};
  if nin==3, sf = vargin{3}; end
else
  error('Wrong number of input arguments.'); 
end


