function xyzout=stream3(varargin)
%STREAM3  3D streamlines.
%   XYZ = STREAM3(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) computes streamlines
%   from vector data U,V,W. The arrays X,Y,Z define the coordinates for
%   U,V,W and must be monotonic and 3D plaid (as if produced by MESHGRID).
%   STARTX, STARTY, and STARTZ define the starting positions of the stream
%   lines. A cell array of vertex arrays is returned in XYZ.  
%   
%   XYZ = STREAM3(U,V,W,STARTX,STARTY,STARTZ) assumes 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U). 
%   
%   XYZ = STREAM3(...,OPTIONS) specifies the options used in creating the
%   streamlines. OPTIONS is specified as a one or two element vector
%   containing the step size and maximum number of vertices in a stream
%   line.  If OPTIONS is not specified the default step size is 0.1 (one
%   tenth of a cell) and the default maximum number of vertices is
%   10000. OPTIONS can either be [stepsize] or [stepsize maxverts].
%   
%   Example:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      streamline(stream3(x,y,z,u,v,w,sx,sy,sz));
%      view(3);
%
%   See also STREAMLINE, STREAM2, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME, 
%            REDUCEVOLUME.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/06/17 13:39:09 $

[x y z u v w sx sy sz step maxvert] = parseargs(nargin,varargin);

% Take this out when other data types are handled
u = double(u);
v = double(v);
w = double(w);


if isempty(step),    step    = .1;    end
if isempty(maxvert), maxvert = 10000; end

if step<=0
  error('Step size must greater than 0.');
end

if maxvert<=0
  error('Maximum number of vertices must greater than 0.');
end

[msg x y z] = xyzuvwcheck(x,y,z,u,v,w);  error(msg)

if ~isequal(size(sx), size(sy), size(sz)) 
  error('STARTX,STARTY,STARTZ must all be the same size.');
end

szu = size(u);

xyz = {};
for k = 1:length(sx)
  if isempty(x)
    xyz{k} = stream3c([],[],[],u,v,w,sx(k),sy(k),sz(k),step,maxvert)';
  else
    xx=x(1,:,1);
    yy=y(:,1,1);
    zz=z(1,1,:);
    
    sxi=interp1(xx(:),1:szu(2),sx(k));
    syi=interp1(yy(:),1:szu(1),sy(k));
    szi=interp1(zz(:),1:szu(3),sz(k));
    if any(isnan([sxi syi szi]))
      xyz{k} = [];
    else
      xyz{k} = stream3c(xx,yy,zz,u,v,w,sxi,syi,szi,step,maxvert)';
    end
  end
end


xyzout=xyz;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w, sx, sy, sz, step, maxvert] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
u = [];
v = [];
w = [];
sx = [];
sy = [];
sz = [];
step = [];
maxvert = [];

options = [];
if nin==6 | nin==7        % stream3(u,v,w,sx,sy,sz)
  u = vargin{1};
  v = vargin{2};
  w = vargin{3};
  sx = vargin{4};
  sy = vargin{5};
  sz = vargin{6};
  if nin==7, options = vargin{7}; end
elseif nin==9 | nin==10    % stream3(x,y,z,u,v,w,sx,sy,sz)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  u = vargin{4};
  v = vargin{5};
  w = vargin{6};
  sx = vargin{7};
  sy = vargin{8};
  sz = vargin{9};
  if nin==10, options = vargin{10}; end
else
  error('Wrong number of input arguments.'); 
end

sx = sx(:); 
sy = sy(:); 
sz = sz(:); 


if ~isempty(options)
  step = options(1);
  if length(options)>=2
    maxvert = options(2);
  end
end
