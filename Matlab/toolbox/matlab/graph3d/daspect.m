function a = daspect(arg1, arg2)
%DASPECT Data aspect ratio.
%   DAR = DASPECT             gets the data aspect ratio of the
%                                current axes. 
%   DASPECT([X Y Z])          sets the data aspect ratio.
%   DARMODE = DASPECT('mode') gets the data aspect ratio mode.
%   DASPECT(mode)             sets the data aspect ratio mode.
%                                (mode can be 'auto' or 'manual')
%   DASPECT(AX,...)           uses axes AX instead of current axes.
%
%   DASPECT sets or gets the DataAspectRatio or DataAspectRatioMode 
%   property of an axes.
%
%   See also PBASPECT, XLIM, YLIM, ZLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 04:28:57 $


% if nargout == 1
%   a = get(gca,'dataaspectratio');
% end

if nargin == 0
  a = get(gca,'dataaspectratio');
else
  if length(arg1)==1 & ishandle(arg1) & strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'dataaspectratio');
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
      a = get(ax,'dataaspectratiomode');
    else
      set(ax,'dataaspectratiomode',val);
    end
  else
    set(ax,'dataaspectratio',val);
  end
end


