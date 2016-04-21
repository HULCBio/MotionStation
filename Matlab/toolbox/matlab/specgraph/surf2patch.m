function [fout, vout, fvcout] = surf2patch( varargin )
%SURF2PATCH  Convert surface data to patch data.
%   FVC = SURF2PATCH(S) converts the geometry and color data from SURFACE
%   object S into PATCH format. The struct FVC contains the faces,
%   vertices and colors of the patch data and can be passed directly to
%   the PATCH command.
%   
%   FVC = SURF2PATCH(Z) calculates patch data from ZData matrix Z.
%   
%   FVC = SURF2PATCH(Z,C) calculates patch data from ZData, and Cdata 
%         matrices Z and C.
%   
%   FVC = SURF2PATCH(X,Y,Z) calculates patch data from XData, YData, and
%         ZData matrices X, Y, and Z.
%   
%   FVC = SURF2PATCH(X,Y,Z,C) calculates patch data from XData, YData,
%         ZData, and Cdata matrices X, Y, Z and C.
%   
%   FVC = SURF2PATCH(...,'triangles') creates triangular faces instead of
%         quadrilaterals. 
%   
%   [F, V, C] = SURF2PATCH(...) returns the faces, vertices and colors in
%               three arrays instead of a struct.
%
%   Example 1:
%      [x y z] = sphere; 
%      patch(surf2patch(x,y,z,z)); 
%      shading faceted; view(3)
%  
%   Example 2:
%      s = surf(peaks);
%      pause;
%      patch(surf2patch(s));
%      delete(s);
%      shading faceted; view(3)
%
%   See also REDUCEPATCH, SHRINKFACES.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/06/17 13:39:12 $

[x y z c triangles] = parseargs(nargin,varargin);

[msg x y] = xyzcheck(x,y,z);  error(msg)

[m n]= size(z);
if isempty(x)
  [x y] = meshgrid(1:n, 1:m);
end


[cm cn cp] = size(c);

if cm==(m-1) & cn==(n-1)
  cmode = 'f';
elseif cm==m & cn==n
  cmode = 'v';
else  
  cmode = '';
end

v = [x(:) y(:) z(:)];
q = [1:m*n-m-1]';
q(m:m:end) = [];

fvc = reshape(c, [cm*cn cp]);

if triangles
  f = [q q+m q+m+1; q q+m+1 q+1];
  if cmode=='f'
    fvc = [fvc; fvc];
  end
else
  f = [q q+m q+m+1 q+1];
end


if nargout <= 1
  fout.faces = f;
  fout.vertices = v;
  if ~isempty(c)
    fout.facevertexcdata = fvc;
  end
else
  fout = f;
  vout = v;
  if ~isempty(c) & nargout==3
    fvcout = fvc;
  else
    fvcout = [];
  end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, c, triangles] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
c = [];
triangles = 0;

if nin>0
  firstarg = vargin{1};
  lastarg = vargin{nin};
  if ischar(lastarg)
    if lastarg(1)=='t'
      triangles = 1;
    end
    nin = nin-1;
  end
end

if nin==1   % surf2patch(s), surf2patch(z)
  if prod(size(firstarg))==1 & ishandle(firstarg) & strcmp(get(firstarg, 'type'), 'surface')
    s = firstarg;
    x = get(s, 'xdata');
    y = get(s, 'ydata');
    z = get(s, 'zdata');
    c = get(s, 'cdata');
  else
    z = firstarg;
  end
elseif nin==2   % surf2patch(z,c)
  z = firstarg;
  c = vargin{2};
elseif nin==3   % surf2patch(x,y,z)
  x = firstarg;
  y = vargin{2};
  z = vargin{3};
elseif nin==4   % surf2patch(x,y,z,c)
  x = firstarg;
  y = vargin{2};
  z = vargin{3};
  c = vargin{4};
else
  error('Wrong number of input arguments.'); 
end
