function h=scribepin(varargin)
%SCRIBEPIN creates the annotation pin object
% 

%   Copyright 1984-2004 The MathWorks, Inc.

args = varargin;
args(1:2:end) = lower(args(1:2:end));
parentind = find(strcmp(args,'parent'));
if isempty(parentind)
  parent = gca;
else
  parent = args{parentind(end)+1}; % take last parent specified
  args(unique([parentind parentind+1]))=[];
end
h = scribe.scribepin('parent',parent,'Visible','on','HandleVisibility','off',...
                     'XLimInclude','off',...
                     'YLimInclude','off',...
                     'ZLimInclude','off',...
                     'CLimInclude','off',...
                     'String',' ',...
                     'HitTest','off',...
                     'Tag','ScribePinText');
if ~isempty(args)
  set(h,args{:})
end

hax = handle(parent);
l = [handle.listener(h,'ObjectBeingDestroyed',@removePin);
     handle.listener(hax,findprop(hax,'WarpToFill'),'PropertyPostSet',{@enablePin,h,hax});
     handle.listener(hax,'AxisInvalidEvent',{@LupdateTarget,h})];

% if object add data listeners
if ~isempty(h.PinnedObject)
  pinobj = handle(h.PinnedObject);
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'XData'), 'PropertyPostSet', {@LchangedPinnedObjData,h});
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'YData'), 'PropertyPostSet', {@LchangedPinnedObjData,h});
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'ZData'), 'PropertyPostSet', {@LchangedPinnedObjData,h});
end

h.Listeners = l;

%-------------------------------------------------------%
function enablePin(hSrc,eventData,h,hax)
if ishandle(h)
  set(h,'Enable',get(hax,'WarpToFill'))
end

%-------------------------------------------------------%
function removePin(hSrc,eventData,h)
if nargin == 3, hSrc = h; end
if ishandle(hSrc.Target)
  pins = hSrc.Target.Pin;
  ind = hSrc == pins;
  if ~isempty(ind)
    pins(ind) = [];
    pinsrect = hSrc.Target.Pinrect;
    delete(pinsrect(ind));
    pinsrect(ind) = [];
    if ~any(ishandle(hSrc.Targe.Pin))
      hSrc.Target.Pin = [];
      hSrc.Target.Pinrect = [];
    else
      hSrc.Target.Pin = pins;
      hSrc.Target.Pinrect = pinsrect;
    end
  end
  delete(hSrc.Listeners);
end

%-------------------------------------------------------%
function LupdateTarget(hProp,eventData,h)

methods(h,'updateTarget');

%-------------------------------------------------------%
function LchangedPinnedObjData(hProp,eventData,h)

methods(h,'changedPinnedObjData');
