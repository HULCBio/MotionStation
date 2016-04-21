function camorbit(ax, dtheta, dphi, coordsys, direction)
%CAMORBIT Orbit camera.
%   CAMORBIT(DTHETA, DPHI)  Orbits (rotates) the camera position
%   of the current axes around the camera target by the amounts
%   specified in DTHETA and DPHI (both in degrees). DTHETA is the
%   horizontal rotation and DPHI is the vertical.
% 
%   CAMORBIT(DTHETA, DPHI, coordsys, direction) determines the center
%   of rotation. Coordsys can be 'data' (the default) or 'camera'.  If
%   coordsys is 'data' (the default), the camera position rotates
%   around a line specified by the camera target and direction.
%   Direction can be 'x', 'y', or 'z' (the default) or [X Y Z].  If
%   coordsys is 'camera', the rotation is around the camera target
%   point. 
%
%   CAMORBIT(AX, ...) uses axes AX instead of the current axes.
%
%   See also CAMDOLLY, CAMPAN, CAMZOOM, CAMROLL.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:28:09 $

if nargin>5 | nargin<2
  error('Wrong number of arguments')
elseif nargin<5
  
  if ishandle(ax) & strcmp(get(ax, 'type'), 'axes')
    if nargin<3 
      error('Wrong number of arguments')
    else
      direction = [0 0 1];
      if nargin==3
	coordsys = 'data';
      end
    end
  else
    if nargin==4
      direction = coordsys;
      coordsys  = dphi;
    elseif nargin==3
      direction = [0 0 1];
      coordsys  = dphi;
    else %nargin==2
      direction = [0 0 1];
      coordsys  = 'data';
    end
    
    dphi   = dtheta;
    dtheta = ax;
    ax     = gca;
  end

end

pos  = get(ax, 'cameraposition' );
targ = get(ax, 'cameratarget'   );
dar  = get(ax, 'dataaspectratio');
up   = get(ax, 'cameraupvector' );

if ~righthanded(ax), dtheta = -dtheta; end

[newPos newUp] = camrotate(pos,targ,dar,up,dtheta,dphi,coordsys,direction);

set(ax, 'cameraposition', newPos, 'cameraupvector', newUp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);

