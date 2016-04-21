function a = camup(arg1, arg2)
%CAMUP Camera up vector.
%   UP = CAMUP              gets the camera up vector of the current
%                              axes. 
%   CAMUP([X Y Z])          sets the camera up vector.
%   UPMODE = CAMUP('mode')  gets the camera up vector mode.
%   CAMUP(mode)             sets the camera up vector mode.
%                              (mode can be 'auto' or 'manual')
%   CAMUP(AX,...)           uses axes AX instead of current axes.
%
%   CAMUP sets or gets the CameraUpVector or CameraUpVectorMode
%   property of an axes.
%
%   See also CAMPOS, CAMTARGET, CAMPROJ, CAMUP.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:28:05 $

if nargin == 0
  a = get(gca,'cameraupvector');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'cameraupvector');
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
      a = get(ax,'cameraupvectormode');
    else
      set(ax,'cameraupvectormode',val);
    end
  else
    set(ax,'cameraupvector',val);
  end
end
