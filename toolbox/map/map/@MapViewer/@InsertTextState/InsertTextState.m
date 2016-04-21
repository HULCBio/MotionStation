function this = InsertTextState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:46 $

this = MapViewer.InsertTextState;

this.MapViewer = viewer;

set(viewer.Figure,'Pointer','ibeam',...
                  'WindowButtonDownFcn',{@doTextInsert viewer});

function doTextInsert(hSrc,event,viewer)
set(viewer.Figure,'WindowButtonDownFcn','',...
                  'CurrentObject',double(viewer.AnnotationAxes));

pt = get(viewer.Axis,'CurrentPoint');
MapGraphics.Text('annotation','Position',[pt(1),pt(3),0],'String',' ',...
                 'EraseMode','normal','Editing','on',...
                 'Parent',double(viewer.AnnotationAxes));

toolbar = findall(viewer.Figure,'type','uitoolbar');
toolButton = findall(toolbar,'Tag','insert text');
set(toolButton,'State','off');
set(viewer.Figure,'Pointer','arrow');
