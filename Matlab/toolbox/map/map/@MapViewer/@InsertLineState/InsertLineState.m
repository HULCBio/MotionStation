function this = InsertLineState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:43 $

this = MapViewer.InsertLineState;

this.MapViewer = viewer;
viewer.Figure.Pointer = 'crosshair';
set(viewer.Figure,'WindowButtonDownFcn',{@insertLine viewer});

function insertLine(hSrc,event,viewer)
MapGraphics.DragLine(double(viewer.AnnotationAxes),false,true);
