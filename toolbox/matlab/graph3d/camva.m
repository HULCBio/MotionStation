function a = camva(arg1, arg2)
%CAMVA Camera view angle.
%   CVA = CAMVA             gets the camera view angle of the current
%                              axes. 
%   CAMVA(val)              sets the camera view angle.
%   CVAMODE = CAMVA('mode') gets the camera view angle mode.
%   CAMVA(mode)             sets the camera view angle mode.
%                              (mode can be 'auto' or 'manual')
%   CAMVA(AX,...)           uses axes AX instead of current axes.
%
%   CAMVA sets or gets the CameraViewAngle or CameraViewAngleMode
%   property of an axes.
%
%   See also CAMPOS, CAMTARGET, CAMPROJ, CAMUP.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 04:28:43 $

% if nargout == 1
%   a = get(gca,'cameraviewangle');
% end

if nargin == 0
  a = get(gca,'cameraviewangle');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'cameraviewangle');
      return
    end
  else
    if nargin==2
      error('Wrong number of arguments')
    else
      ax = gca;
      val = arg1;
    end
  end
    
  if isstr(val)
    if(strcmp(val,'mode'))
      a = get(ax,'cameraviewanglemode');
    else
      set(ax,'cameraviewanglemode',val);
    end
  else
    set(ax,'cameraviewangle',val);
  end
end


