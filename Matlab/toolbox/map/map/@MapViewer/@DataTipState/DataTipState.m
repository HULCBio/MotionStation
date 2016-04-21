function this = DataTipState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:56:25 $

if ~isempty(viewer.PreviousDataTipState)
    this = viewer.PreviousDataTipState;
    viewer.PreviousDataTipState = [];
else
    this = MapViewer.DataTipState;
end

this.Viewer = viewer;

if ~isempty(findstr(version,'R14'))
  iconroot = [matlabroot '/toolbox/map/icons/'];
else
  % For R13 the toolbox/map/icons directory must be on the path.
  iconroot = '';
end

this.Viewer.Figure.Pointer = 'crosshair';

%icon = double(imread([iconroot 'tool_datatip_cursor.bmp']));
%icon(icon==255) = NaN; % NaN = transparent
%icon(icon==0) = 1; % 1 = Black
%
%this.Viewer.Figure.Pointer = 'custom';
%this.Viewer.Figure.PointerShapeCData = icon;

if isempty(viewer.UtilityAxes)
  viewer.UtilityAxes =  MapViewer.AnnotationLayer(viewer.Axis);
end 

this.ActiveLayerDisplay = viewer.DisplayPane.ActiveLayerDisplay;

%if strcmp(lower(viewer.ActiveLayerName),'none') || ...
%      isempty(viewer.ActiveLayerName)
%  h = warndlg('The Active Layer has not been set.','No Active Layer','modal');
%end

this.setActiveLayer(viewer,viewer.ActiveLayerName);


