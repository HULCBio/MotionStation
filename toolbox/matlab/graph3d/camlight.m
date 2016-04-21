function ret = camlight(varargin)
%CAMLIGHT Create or set position of a light.
%   CAMLIGHT HEADLIGHT creates a light in the current axes at the
%                         camera position of the current axes. 
%   CAMLIGHT RIGHT     creates a light right and up from camera.
%   CAMLIGHT LEFT      creates a light left and up from camera.
%   CAMLIGHT           same as CAMLIGHT RIGHT.
%   CAMLIGHT(AZ, EL)   creates a light at AZ, EL from camera.
%
%   CAMLIGHT(..., style) set the style of the light.
%                 Style can be 'local' (default) or 'infinite'.
%                
%   CAMLIGHT(H, ...)   places specified light at specified position.
%   H = CAMLIGHT(...)  returns light handle.
%
%   CAMLIGHT creates or positions a light in the coordinate system of 
%   the camera. For example, if both AZ and EL are zero, the light 
%   will be placed at the camera's position.  In order for a light 
%   created with CAMLIGHT to stay in a constant position relative to 
%   the camera, CAMLIGHT must be called whenever the camera is moved.
%
%   See also LIGHT, LIGHTANGLE, LIGHTING, MATERIAL, CAMORBIT.
 
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/10 23:26:45 $


defaultAz = 30;
defaultEl = 30;
defaultStyle = 'local';
createLight = 0;

if nargin>4
  error('Too many arguments')
else  
  args = varargin;
  if ~isempty(args) & isnumeric(args{1}) & length(args{1}) > 1
    error('First numeric argument must be a handle to a single light object');
  end

  if ~isempty(args) & ishandle(args{1}) & strcmp(get(args{1}, 'type'), 'light')
    h = args{1};
    args(1) = [];
  else
    createLight = 1;
  end
  
  if ~isempty(args) & validString(args{end})==2
    style = args{end};
    args(end) = [];
  else
    style = defaultStyle;
  end
  
  len = length(args);
  if len > 2
    error('Invalid arguments');
  elseif len==1
    [c az el] = validString(args{1});
    if c~=1
      error([num2str(args{1}) ' is an invalid argument']);
    end
  elseif len==2
    az = args{1};
    el = args{2};
    if ~(isnumeric(az) & isreal(az) & isnumeric(el) & isreal(el))
      error([num2str(az) ' and ' num2str(el) ' are not valid arguments']);
    end
  else
    az = defaultAz; el = defaultEl;
  end
end

if createLight == 1;
  h = light;
end

ax = ancestor(h, 'axes');
pos  = get(ax, 'cameraposition' );
targ = get(ax, 'cameratarget'   );
dar  = get(ax, 'dataaspectratio');
up   = get(ax, 'cameraupvector' );

if ~righthanded(ax), az = -az; end

[newPos newUp] = camrotate(pos,targ,dar,up,az,el,'camera',[]);

if style(1)=='i'
  newPos = newPos-targ;
  newPos = newPos/norm(newPos);
end
set(h, 'position', newPos, 'style', style);

if nargout>0
  ret = h;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, az, el]= validString(str)

defaultAz = 30;
defaultEl = 30;
az = 0; el = 0;

if ischar(str)
  c1 = lower(str(1));
  
  if length(str)>1
    c2 = lower(str(2));
  else
    c2 = [];
  end
  
  if c1=='r'        %right
    ret = 1;
    az = defaultAz; el = defaultEl;
  elseif c1=='h'    %headlight
    ret = 1;
    az = 0; el = 0;
  elseif c1=='i'    %infinite
    ret = 2;
  elseif c1=='l' & ~isempty(c2)
    if c2=='o'      %local
      ret = 2;
    elseif c2=='e'  %left
      ret = 1;
      az = -defaultAz; el = defaultEl;
    else
      ret = 0;
    end
  else
    ret = 0;
  end
else
  ret = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);

