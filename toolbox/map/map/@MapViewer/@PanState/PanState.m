function this = PanState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:57:11 $

this = MapViewer.PanState;

this.MapViewer = viewer;

viewer.setDefaultState;
setptr(viewer.Figure,'hand');
set(viewer.Figure,'WindowButtonDownFcn',{@localStartPan viewer});
set(viewer.Figure,'WindowButtonUpFcn','');

function localStartPan(hSrc,event,viewer)
setptr(viewer.Figure,'closedhand');
p  = get(viewer.Axis,'CurrentPoint');
startPt = [p(1) p(3)];
set(viewer.Figure,'WindowButtonUpFcn',{@localStopPan viewer});
set(viewer.Figure,'WindowButtonMotionFcn',{@localPan startPt viewer});

function localPan(hSrc,event,startPt,viewer)
initialXLim = get(viewer.Axis,'XLim');
initialYLim = get(viewer.Axis,'YLim');
p = get(viewer.Axis,'CurrentPoint');
p = [p(1), p(3)];
d = p - startPt;
set(viewer.Axis,'XLim',initialXLim - d(1));
set(viewer.Axis,'YLim',initialYLim - d(2));  

function localStopPan(hSrc,event,viewer)
setptr(viewer.Figure,'hand');
set(viewer.Figure,'WindowButtonMotionFcn',{@updateXYDisplay viewer});
set(viewer.Figure,'WindowButtonUpFcn','');
viewer.Axis.updateOriginalAxis;
vEvent = MapViewer.ViewChanged(viewer);
viewer.send('ViewChanged',vEvent);

function updateXYDisplay(hSrc,event,viewer)
p = get(viewer.Axis,'CurrentPoint');
set(viewer.XDisplay,'String',num2str(p(1),'%0.2f'));
set(viewer.YDisplay,'String',num2str(p(3),'%0.2f'));


