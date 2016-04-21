function hout=streamline(varargin)
%STREAMLINE  Streamlines from 2D or 3D vector data.
%   STREAMLINE(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) creates streamlines
%   from 3D vector data U,V,W. The arrays X,Y,Z define the coordinates for
%   U,V,W and must be monotonic and 3D plaid (as if produced by MESHGRID). 
%   STARTX, STARTY, and STARTZ define the starting positions of the stream
%   lines.
%   
%   STREAMLINE(U,V,W,STARTX,STARTY,STARTZ) assumes 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U). 
%   
%   STREAMLINE(XYZ) assumes XYZ is a precomputed cell array of vertex
%       arrays (as if produced by STREAM3).
%   
%   STREAMLINE(X,Y,U,V,STARTX,STARTY) creates streamlines from 2D
%   vector data U,V. The arrays X,Y define the coordinates for U,V and
%   must be monotonic and 2D plaid (as if produced by MESHGRID). STARTX
%   and STARTY define the starting positions of the streamlines. A vector
%   of line handles is returned.
%   
%   STREAMLINE(U,V,STARTX,STARTY) assumes 
%         [X Y] = meshgrid(1:N, 1:M) where [M,N]=SIZE(U). 
%   
%   STREAMLINE(XY) assumes XY is a precomputed cell array of vertex
%       arrays (as if produced by STREAM2).
%   
%   STREAMLINE(AX,...) plots into AX instead of GCA.
%
%   STREAMLINE(...,OPTIONS) specifies the options used in creating
%   the streamlines. OPTIONS is specified as a one or two element vector
%   containing the step size and maximum number of vertices in a stream
%   line.  If OPTIONS is not specified the default step size is 0.1 (one
%   tenth of a cell) and the default maximum number of vertices is
%   10000. OPTIONS can either be [stepsize] or [stepsize maxverts].
%   
%   H = STREAMLINE(...) returns a vector of line handles.
%
%   Example:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      h=streamline(x,y,z,u,v,w,sx,sy,sz);
%      set(h, 'Color', 'red');
%      view(3);
%
%   See also STREAM3, STREAM2, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME,
%            REDUCEVOLUME.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2004/04/10 23:32:22 $

[cax,args,nargs] = axescheck(varargin{:});
[verts x y z u v w sx sy sz options] = parseargs(nargs,args);

if isempty(cax)
    cax = gca;
end

if isempty(verts)
  if isempty(w)       % 2D
    if isempty(x)
      verts = stream2(u,v,sx,sy,options);
    else
      verts = stream2(x,y,u,v,sx,sy,options);
    end
  else                % 3D
    if isempty(x)
      verts = stream3(u,v,w,sx,sy,sz,options);
    else
      verts = stream3(x,y,z,u,v,w,sx,sy,sz,options);
    end
  end
end

h = [];
for k = 1:length(verts);
  vv = verts{k};
  if ~isempty(vv)
    if size(vv,2)==3
      h = [h ; line('xdata', vv(:,1), 'ydata', vv(:,2), 'zdata', vv(:,3), ...
              'color', [0 0 1], 'parent', cax)];
    else
      h = [h ; line('xdata', vv(:,1), 'ydata', vv(:,2), ...
              'color', [0 0 1], 'parent', cax)];
    end
  end
end

% Register handles with m-code generator
if ~isempty(h)
   mcoderegister('Handles',h,'Target',h(1),'Name','streamline');
end

if nargout>0
  hout=h;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [verts, x, y, z, u, v, w, sx, sy, sz, options] = parseargs(nin, vargin)

[verts, x, y, z, u, v, w, sx, sy, sz, options] = deal([]);

if nin==1  % streamline(xyz) or  streamline(xy) 
  verts = vargin{1};
  if ~iscell(verts)
    error('Stream vertices must be passed in as a cell array')
  end
elseif nin==4 | nin==5           % streamline(u,v,sx,sy)
  [u, v, sx, sy] = deal(vargin{1:4});
  if nin==5, options = vargin{5}; end
elseif nin==6 | nin==7        % streamline(u,v,w,sx,sy,sz) or streamline(x,y,u,v,sx,sy)
  u = vargin{1};
  v = vargin{2};
  if ndims(u)==3
    [w, sx, sy, sz] = deal(vargin{3:6});
  else
    x = u;
    y = v;
    [u, v, sx, sy] = deal(vargin{3:6});
  end
  if nin==7, options = vargin{7}; end
elseif nin==9 | nin==10     % streamline(x,y,z,u,v,w,sx,sy,sz)
  [x, y, z, u, v, w, sx, sy, sz] = deal(vargin{1:9});
  if nin==10, options = vargin{10}; end
else
  error('Wrong number of input arguments.'); 
end

sx = sx(:); 
sy = sy(:); 
sz = sz(:); 


