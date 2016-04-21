function this = SelectAreaState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:57:14 $


this = MapViewer.SelectAreaState;

this.MapViewer = viewer;
this.NewViewAreaMenu = viewer.NewViewAreaMenu;
this.ExportAreaMenu = viewer.ExportAreaMenu;

viewer.setDefaultState;

if isempty(viewer.UtilityAxes)
    viewer.UtilityAxes =  MapViewer.AnnotationLayer(viewer.Axis);
end
set(viewer.Figure,'Pointer','crosshair');
set(viewer.Figure,'WindowButtonDownFcn',{@dragRect this viewer});
set(viewer.Figure,'WindowButtonUpFcn',{@endDragRect this viewer});
%set(viewer.Figure,'ButtonDownFcn',{@deselectArea this viewer});

function dragRect(hSrc,event,this,viewer)
% We ignore right clicks
if ~strcmp(get(hSrc,'SelectionType'),'normal')
  return
end
deselectArea(this,viewer)
corner1 = viewer.getMapCurrentPoint;
corner1Figure = viewer.getFigureCurrentPoint;
showHidden = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
finalRect = rbbox;
set(0,'ShowHiddenHandles',showHidden);
corner2 = viewer.getMapCurrentPoint;
corner2Figure = viewer.getFigureCurrentPoint;

p1 = min(corner1,corner2);
p2 = max(corner1,corner2);
p1Figure = min(corner1Figure,corner2Figure);
p2Figure = max(corner1Figure,corner2Figure);

% If this is a regular click outside the selected area 
% we simply return 
if (p1 == p2)
  return
end

viewer.SelectionBox = [p1;p2];
viewer.FigureSelectionBox = [p1Figure; p2Figure];

offset = abs(corner1-corner2);         
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

this.Box = MapGraphics.Line('SelectionBox',...
                            'Parent',double(viewer.UtilityAxes),...
                            'XData',x,'YData',y,'color','r','linewidth',1,...
                            'Tag','selectAreaBox');
this.enableMenus;

function endDragRect(hSrc,event,this,viewer)
set(viewer.Figure,'WindowButtonDownFcn','');
set(viewer.Figure,'WindowButtonUpFcn','');
%reset(this,viewer);

%function reset(this,viewer)
set(viewer.Figure,'WindowButtonDownFcn',{@dragRect this viewer});
set(viewer.Figure,'WindowButtonUpFcn',{@endDragRect this viewer});

function deselectArea(this,viewer)
selectAreaBox = findobj(viewer.UtilityAxes.Children,'Tag','selectAreaBox');
if ~isempty(selectAreaBox)
  delete(selectAreaBox);
end

