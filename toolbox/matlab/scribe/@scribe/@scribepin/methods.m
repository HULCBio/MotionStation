function val = methods(this,fcn,varargin)
% METHODS - methods for scribepin class

%   Copyright 1984-2004 The MathWorks, Inc.

if nargout>0
    val = [];
end

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

args = {fcn,this,varargin{:}};
if nargout == 0
  feval(args{:});
else
  val = feval(args{:});
end

%-------------------------------------------------------%
function repin(h,point,pinax,pinobj)

set(h,'Enable','off');
l = h.Listeners;
l = l(1); % save delete listener;

set(h,'Parent',pinax);
set(h,'PinnedObject',pinobj);

hax = handle(pinax);
l(end+1) = handle.listener(hax,'AxisInvalidEvent',{@updateTarget_cb,h});

% if object add data listeners
if ~isempty(h.PinnedObject)
  pinobj = handle(h.PinnedObject);
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'XData'), 'PropertyPostSet', {@changedPinnedObjData_cb,h});
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'YData'), 'PropertyPostSet', {@changedPinnedObjData_cb,h});
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'ZData'), 'PropertyPostSet', {@changedPinnedObjData_cb,h});
end

h.Listeners = l;

%-------------------------------------------------------%
function updateTarget(pin)

if ishandle(pin) && strcmp(pin.Enable,'on')

  scribeax = getappdata(ancestor(pin,'figure'),'Scribe_ScribeOverlay');
  if ishandle(scribeax)
    invalidateaxis(double(scribeax));
  end

  h = pin.Target;
  if isprop(h,'shapeType')
    h.methods('update_position_from_pintext',pin);
  end
end

function updateTarget_cb(hSrc,evdata,h)
updateTarget(h);

%-------------------------------------------------------%
function changedPinnedObjData(h)
delete(h);

function changedPinnedObjData_cb(hSrc,evdata,h)
changedPinnedObjData(h)