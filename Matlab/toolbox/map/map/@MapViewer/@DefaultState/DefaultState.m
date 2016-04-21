function this = DefaultState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:33 $

this = MapViewer.DefaultState;

set(viewer.Figure,'WindowButtonMotionFcn',{@updateXYDisplay viewer});
set(viewer.Figure,'WindowButtonUpFcn','');

% Menus
viewer.NewViewAreaMenu.Enable = 'off';
viewer.ExportAreaMenu.Enable = 'off';

function updateXYDisplay(hSrc,event,viewer)
p = get(viewer.Axis,'CurrentPoint');
set(viewer.XDisplay,'String',num2str(p(1),'%0.2f'));
set(viewer.YDisplay,'String',num2str(p(3),'%0.2f'));


