function a = xlim(arg1, arg2)
%XLIM X limits.
%   XL = XLIM             gets the x limits of the current axes.
%   XLIM([XMIN XMAX])     sets the x limits.
%   XLMODE = XLIM('mode') gets the x limits mode.
%   XLIM(mode)            sets the x limits mode.
%                            (mode can be 'auto' or 'manual')
%   XLIM(AX,...)          uses axes AX instead of current axes.
%
%   XLIM sets or gets the XLim or XLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, YLIM, ZLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:28:47 $

if nargin == 0
  a = get(gca,'xlim');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'xlim');
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
      a = get(ax,'xlimmode');
    else
      set(ax,'xlimmode',val);
    end
  else
    set(ax,'xlim',val);
  end
end
