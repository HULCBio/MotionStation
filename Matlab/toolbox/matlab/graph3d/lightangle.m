function [azOut, elOut] = lightangle(h, az, el);
%LIGHTANGLE Spherical position of a light. 
%   LIGHTANGLE(AZ, EL)      creates a light in the current axes at the
%                              specified position. 
%   H = LIGHTANGLE(AZ, EL)  creates a light and returns its handle.
%   LIGHTANGLE(H, AZ, EL)   sets the position of the specified light.
%   [AZ EL] = LIGHTANGLE(H) gets the position of the specified light.
%
%   LIGHTANGLE creates or positions a light using azimuth and 
%   elevation.  AZ is the azimuth or horizontal rotation and EL is the 
%   vertical elevation (both in degrees).  The interpretation of azimuth 
%   and elevation are exactly the same as with the VIEW command.  
%   When a light is created, its style is 'infinite'.  If the light 
%   passed into lightangle is a local light, the distance between the 
%   light and the camera target is preserved.
%
%   See also LIGHT, CAMLIGHT, LIGHTING, MATERIAL, VIEW.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 04:28:23 $

if nargin>3 | nargin<1
  error('Wrong number of arguments')
elseif nargin==2
  el = az;
  az = h;
  h=light;
elseif length(h) > 1 | ~ishandle(h) | ~strcmp(get(h, 'type'), 'light')
  error('H must be a handle to a single light object')
end

if nargin==3 & nargout>1
  error('Wrong number of output arguments')
end

ct  = get(gca, 'cameratarget'   );
dar = get(gca, 'dataaspectratio');

if strcmp(get(h, 'style'), 'local')
  dif = (get(h, 'pos')-ct)./dar;
else
  dif =  get(h, 'pos')./dar;
end

dis = norm(dif);

if nargin==1  %getting
  rad2deg = 180/pi;
  azOut = atan2(dif(2),dif(1))+pi/2;
  elOut = asin( dif(3)/dis );
  azOut = azOut*rad2deg;
  elOut = elOut*rad2deg;
else         %setting
  if ~isnumeric([az el]) | length(az) > 1 | length(el) > 1
    error('AZ and EL must both be scalars')
  end
  deg2rad = pi/180;
  az = az*deg2rad;

  if mod(el-90,180)==0
    newPos = [0 0 sin(el)];
  else
    el = el*deg2rad;
    newPos = [sin(az)*cos(el) -cos(az)*cos(el) sin(el)];
  end

  if strcmp(get(h, 'style'), 'local')
    pos = ct+newPos*dis.*dar;
  else
    pos = newPos*dis.*dar;
  end
  
  set(h, 'pos', pos);
  if nargout==1
    azOut = h;
  end
end

