function a = ylim(arg1, arg2)
%YLIM Y limits.
%   YL = YLIM             gets the y limits of the current axes.
%   YLIM([YMIN YMAX])     sets the y limits.
%   YLMODE = YLIM('mode') gets the y limits mode.
%   YLIM(mode)            sets the y limits mode.
%                            (mode can be 'auto' or 'manual')
%   YLIM(AX,...)          uses axes AX instead of current axes.
%
%   YLIM sets or gets the YLim or YLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM, ZLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:28:51 $

if nargin == 0
  a = get(gca,'ylim');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'ylim');
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
      a = get(ax,'ylimmode');
    else
      set(ax,'ylimmode',val);
    end
  else
    set(ax,'ylim',val);
  end
end
