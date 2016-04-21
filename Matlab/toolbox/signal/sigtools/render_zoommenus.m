function hzoommenus = render_zoommenus(hFig,position)
%RENDER_ZOOMMENUS Render the Zoom In and Zoom Out menus.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/11/21 15:35:50 $ 

strs  = {xlate('Zoom In'),xlate('Zoom X'),xlate('Zoom Y'),xlate('Full View')};
cbs   = zoom_cbs(hFig);
cbs   = {cbs.zoom_clickedcb,cbs.zoom_clickedcb,...
        cbs.zoom_clickedcb,cbs.zoom_clickedcb};
tags  = {'zoomin','zoomx','zoomy','fullview'}; 
sep   = {'Off','Off','Off','Off'};
accel = {'','','',''};

hzoommenus = addmenu(hFig,position,strs,cbs,tags,sep,accel);
sigsetappdata(hFig, 'siggui', 'ZoomMenus', hzoommenus);

if nargout>0,
    varargout{1} = hzoommenus;
end

% [EOF]
