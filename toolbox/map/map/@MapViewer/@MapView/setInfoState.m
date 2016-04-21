function setInfoState(this,onoff)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:15:03 $

this.setDefaultState;
activeLayerHandles = this.Axis.getLayerHandles(this.ActiveLayerName);
if onoff
  this.State = 'info';
  if isempty(this.UtilityAxes)
    this.UtilityAxes =  MapViewer.AnnotationLayer(this.Axis);
  end 
  activeLayerHandles = handle(this.Axis.getLayerHandles(this.ActiveLayerName));
  set(activeLayerHandles,'ButtonDownFcn',{@datatipMode this activeLayerHandles});
  set(this.Figure,'WindowButtonDownFcn','');
  set(this.Figure,'WindowButtonUpFcn','');
  set(this.Figure,'Pointer','arrow');
else
  set(activeLayerHandles,'ButtonDownFcn','');
  delete(get(this.UtilityAxes,'Children'));
end

