function a = alim(arg1, arg2)
%ALIM Alpha limits.
%   AL = ALIM             gets the alpha limits of the current axes.
%   ALIM([AMIN AMAX])     sets the alpha limits.
%   ALMODE = ALIM('mode') gets the alpha limits mode.
%   ALIM(mode)            sets the alpha limits mode.
%                            (mode can be 'auto' or 'manual')
%   ALIM(AX,...)          uses axes AX instead of current axes.
%
%   ALIM sets or gets the Alim or AlimMode property of an axes.
%
%   See also ALPHA, ALPHAMAP, CAXIS, COLORMAP.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 04:27:25 $

if nargin == 0
  a = get(gca,'alim');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'alim');
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
      a = get(ax,'alimmode');
    else
      set(ax,'alimmode',val);
    end
  else
    set(ax,'alim',val);
  end
end
