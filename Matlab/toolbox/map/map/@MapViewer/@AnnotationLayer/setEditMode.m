function setEditMode(this,editing)
%SetEditMode Turns edit mode on/off
%
%   SetEditMode(EDITING).  If EDITING is true, then the layer is edtiable. The
%   objects in the layer must have a setEditMode method.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:24 $

children = handle(get(this,'Children'));
fig = get(this,'Parent');
axesView = [double(this.MasterAxes); get(this.MasterAxes,'Children')];

% Only one object selected at a time
set(children,'Selected','off');

if editing
  for i = 1:length(children)
    children(i).setEditMode(true);
  end
  set(fig,'KeyPressFcn',{@keypress this});
  set(axesView,'ButtonDownFcn',{@annotationSelection this});
else
  set(children,'Selected','off','ButtonDownFcn','');
  set(fig,'KeyPressFcn','');
  set(axesView,'ButtonDownFcn','');
  set(this,'Visible','off');
end

function keypress(hSrc,event,this)
obj = findall(double(this),'Selected','on');
if ~isempty(obj)
  fig = get(this,'Parent');
  
  if strcmp(get(fig,'CurrentCharacter'),char(127)) ||...
        strcmp(get(fig,'CurrentCharacter'),char(8))
    delete(obj);
  end
  set(fig,'WindowButtonMotionFcn','');
  set(fig,'WindowButtonUpFcn','');
end

function annotationSelection(hSrc,event,this)
% Enables deselecting selected annotations by clicking on the axes
obj = findall(double(this),'Selected','on');

if ~isempty(obj)
  set(obj,'Selected','off');
end
