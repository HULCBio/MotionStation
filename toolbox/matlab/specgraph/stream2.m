function xyout=stream2(varargin)
%STREAM2  2D streamlines.
%   XY = STREAM2(X,Y,U,V,STARTX,STARTY) computes streamlines from vector
%   data U,V. The arrays X,Y define the coordinates for U,V and must be
%   monotonic and 2D plaid (as if produced by MESHGRID).  STARTX and
%   STARTY define the starting positions of the streamlines. A cell array
%   of vertex arrays is returned in XY.
%   
%   XY = STREAM2(U,V,STARTX,STARTY) assumes [X Y] = meshgrid(1:N, 1:M)
%        where[M,N]=SIZE(U).  
%
%   XY = STREAM2(...,OPTIONS) specifies the options used in creating the
%   streamlines. OPTIONS is specified as a one or two element vector
%   containing the step size and maximum number of vertices in a stream
%   line.  If OPTIONS is not specified the default step size is 0.1 (one
%   tenth of a cell) and the default maximum number of vertices is
%   10000. OPTIONS can either be [stepsize] or [stepsize maxverts].
%   
%   Example:
%      load wind
%      [sx sy] = meshgrid(80, 20:10:50);
%      streamline(stream2(x(:,:,5),y(:,:,5),u(:,:,5),v(:,:,5),sx,sy));
%
%   See also STREAMLINE, STREAM3, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME, 
%            REDUCEVOLUME. 

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/06/17 13:39:08 $

[x y u v sx sy step maxvert] = parseargs(nargin,varargin);

% Take this out when other data types are handled
u = double(u);
v = double(v);

if isempty(step),    step    = .1;    end
if isempty(maxvert), maxvert = 10000; end

if step<=0
  error('Step size must greater than 0.');
end

if maxvert<=0
  error('Maximum number of vertices must greater than 0.');
end

[msg x y] = xyuvcheck(x,y,u,v);  error(msg)

if ~isequal(size(sx), size(sy)) 
  error('STARTX,STARTY must all be the same size.');
end

szu = size(u);

xy = {};
for k = 1:length(sx)
  if isempty(x)
    xy{k} = stream3c([],[],[],u,v,[],sx(k),sy(k),[],step,maxvert)';
  else
    xx=x(1,:);
    yy=y(:,1);
    
    sxi=interp1(xx(:),1:szu(2),sx(k));
    syi=interp1(yy(:),1:szu(1),sy(k));
    if any(isnan([sxi syi]))
      xy{k} = [];
    else
      xy{k} = stream3c(xx,yy,[],u,v,[],sxi,syi,[],step,maxvert)';
    end
  end
end

xyout=xy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, u, v, sx, sy, step, maxvert] = parseargs(nin, vargin)

x = [];
y = [];
u = [];
v = [];
sx = [];
sy = [];
step = [];
maxvert = [];

options = [];
if nin==4 | nin==5         % stream2(u,v,sx,sy)
  u = vargin{1};
  v = vargin{2};
  sx = vargin{3};
  sy = vargin{4};
  if nin==5, options = vargin{5}; end
elseif nin==6  | nin==7    % stream2(x,y,u,v,sx,sy)
  x = vargin{1};
  y = vargin{2};
  u = vargin{3};
  v = vargin{4};
  sx = vargin{5};
  sy = vargin{6};
  if nin==7, options = vargin{7}; end
else
  error('Wrong number of input arguments.'); 
end

sx = sx(:); 
sy = sy(:); 

if ~isempty(options)
  step = options(1);
  if length(options)>=2
    maxvert = options(2);
  end
end
