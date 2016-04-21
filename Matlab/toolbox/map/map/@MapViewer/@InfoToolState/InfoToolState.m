function this = InfoToolState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:38 $


if isempty(viewer.PreviousInfoToolState)
  this = MapViewer.InfoToolState;
else
  this = viewer.PreviousInfoToolState;
  viewer.PreviousInfoToolState = [];
end

this.Viewer = viewer;
viewer.Figure.Pointer = 'crosshair';
this.setActiveLayer(viewer, viewer.ActiveLayerName);