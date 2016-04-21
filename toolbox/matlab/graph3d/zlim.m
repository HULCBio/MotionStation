function a = zlim(arg1, arg2)
%ZLIM Z limits.
%   ZL = ZLIM             gets the z limits of the current axes.
%   ZLIM([ZMIN ZMAX])     sets the z limits.
%   ZLMODE = ZLIM('mode') gets the z limits mode.
%   ZLIM(mode)            sets the z limits mode.
%                            (mode can be 'auto' or 'manual')
%   ZLIM(AX,...)          uses axes AX instead of current axes.
%
%   ZLIM sets or gets the ZLim or ZLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM, YLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:28:55 $

if nargin == 0
  a = get(gca,'zlim');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'zlim');
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
      a = get(ax,'zlimmode');
    else
      set(ax,'zlimmode',val);
    end
  else
    set(ax,'zlim',val);
  end
end
