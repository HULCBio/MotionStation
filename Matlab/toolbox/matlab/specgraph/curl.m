function [curlx, curly, curlz, cav] = curl(varargin)
%CURL  Curl and angular velocity of a vector field.
%   [CURLX, CURLY, CURLZ, CAV] = CURL(X,Y,Z,U,V,W) computes the
%   curl and angular velocity perpendicular to the flow (in radians
%   per time unit) of a 3D vector field U,V,W. The arrays X,Y,Z
%   define the coordinates for U,V,W and must be monotonic and 3D 
%   plaid (as if produced by MESHGRID).   
%   
%   [CURLX, CURLY, CURLZ, CAV] = CURL(U,V,W) assumes 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U). 
%
%   [CURLZ, CAV]= CURL(X,Y,U,V) computes the curl z component and
%   angular velocity perpendicular to z (in radians per time unit)
%   of a 2D vector field U,V. The arrays X,Y define the
%   coordinates for U,V and must be monotonic and 2D plaid (as if
%   produced by MESHGRID).       
%   
%   [CURLZ, CAV] = CURL(U,V) assumes 
%         [X Y] = meshgrid(1:N, 1:M) where [M,N]=SIZE(U). 
%   
%   [CURLX, CURLY, CURLZ] = CURL(...) or 
%         [CURLX, CURLY] = CURL(...) returns only the curl.
%   
%   CAV = CURL(...) returns only the curl angular velocity.
%   
%   Example 1:
%      load wind
%      cav = curl(x,y,z,u,v,w);
%      slice(x,y,z,cav,[90 134],[59],[0]); shading interp
%      daspect([1 1 1])
%      camlight
%
%   Example 2:
%      load wind
%      k = 4; 
%      x = x(:,:,k); y = y(:,:,k); u = u(:,:,k); v = v(:,:,k); 
%      cav = curl(x,y,u,v);
%      pcolor(x,y,cav); shading interp
%      hold on; quiver(x,y,u,v)
%
%   See also STREAMRIBBON, DIVERGENCE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:38:00 $

[x y z u v w] = parseargs(nargin,varargin);

% Take this out when other data types are handled
u = double(u);
v = double(v);
w = double(w);

if isempty(w)  % 2D
 
  [msg x y] = xyuvcheck(x,y,u,v);  error(msg)
  
  if isempty(x)
    [junk py] = gradient(u);
    [qx junk] = gradient(v);
  else
    hx = x(1,:); 
    hy = y(:,1); 
    [junk py] = gradient(u, hx, hy);
    [qx junk] = gradient(v, hx, hy);
  end

  curlz = qx-py; 
  if nargout==2 
    curlx = curlz;      % curlz
    curly = .5 * curlz; % cav
  else
    curlx = .5 * curlz; % cav
  end
  
else   %3D
  
  [msg x y z] = xyzuvwcheck(x,y,z,u,v,w);  error(msg)
  
  if isempty(x)
    [junk py pz] = gradient(u);
    [qx junk qz] = gradient(v);
    [rx ry junk] = gradient(w);
  else
    hx = x(1,:,1); 
    hy = y(:,1,1); 
    hz = z(1,1,:); 
    [junk py pz] = gradient(u, hx, hy, hz);
    [qx junk qz] = gradient(v, hx, hy, hz);
    [rx ry junk] = gradient(w, hx, hy, hz);
  end

  curlx = ry-qz;
  curly = pz-rx;
  curlz = qx-py;

  if nargout==4 | nargout==1
    nrm = sqrt(u.^2 + v.^2 + w.^2);
    cav = .5 * (curlx.*u + curly.*v + curlz.*w) ./nrm;
  end

  if nargout==1
    curlx = cav;
  end
  
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
u = [];
v = [];
w = [];

if nin==2         % curl(u,v)
  u = vargin{1};
  v = vargin{2};
elseif nin==3     % curl(u,v,w)
  u = vargin{1};
  v = vargin{2};
  w = vargin{3};
elseif nin==4     % curl(x,y,u,v)
  x = vargin{1};
  y = vargin{2};
  u = vargin{3};
  v = vargin{4};
elseif nin==6     % curl(x,y,z,u,v,w)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  u = vargin{4};
  v = vargin{5};
  w = vargin{6};
else
  error('Wrong number of input arguments.'); 
end
