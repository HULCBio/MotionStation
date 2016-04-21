function a = camproj(arg1, arg2)
%CAMPROJ Camera projection.
% 
%   PROJ = CAMPROJ       gets the camera projection of the current
%                           axes. 
%   CAMPROJ(projection)  sets the camera projection.  
%   CAMPROJ(AX,...)      uses axes AX instead of current axes.
%
%   Projection can be 'orthographic' (default) or 'perspective'. 
%
%   CAMPROJ sets or gets the Projection property of an axes.
%
%   See also CAMPOS, CAMTARGET, CAMVA, CAMUP.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 04:28:59 $

if nargin == 0
  ax = gca;
  a = get(ax,'projection');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'projection');
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
    
  set(ax,'projection',val);
end

if nargout == 1
  a = get(ax,'projection');
end

