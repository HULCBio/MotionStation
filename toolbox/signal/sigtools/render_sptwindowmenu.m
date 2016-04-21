function hwindow = render_sptwindowmenu(hFig, pos)
%RENDER_SPTWINDOWMENU Render a Signal Processing Toolbox "Window" menu.
%   HWINDOW = RENDER_SPTWINDOWMENU(HFIG, POS) creates a "Window" menu in POS position
%   on a figure whose handle is HFIG and return the handles to all the menu items.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:53:09 $ 

strs  = '&Window';
cbs   = 'winmenu(gcbo);';
tags  = 'winmenu'; 
sep   = 'off';
accel = '';
hwindow = addmenu(hFig,pos,strs,cbs,tags,sep,accel);
winmenu(hFig);


% [EOF]
