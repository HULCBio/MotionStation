function this = InsertArrowState(viewer,mode)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:37 $

this = MapViewer.InsertArrowState;

this.MapViewer = viewer;
viewer.Figure.Pointer = 'crosshair';
set(viewer.Figure,'WindowButtonDownFcn',{@insertLine viewer});

function insertLine(hSrc,event,viewer)
MapGraphics.DragLine(double(viewer.AnnotationAxes),true,true);

