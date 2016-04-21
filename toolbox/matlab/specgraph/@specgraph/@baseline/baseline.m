function h = baseline(varargin)
%BASELINE baseline constructor
%  This function is an internal helper function for Handle Graphics
%  and shouldn't be called directly.
  
%   Copyright 1984-2004 The MathWorks, Inc. 

h = specgraph.baseline(...
    'xliminclude','off',...
    'yliminclude','off',...
    'zliminclude','off',...
    varargin{:});
ax = ancestor(h,'axes');
h.color = get(ax,'xcolor');
h.xdata = get(ax,'xlim');
h.ydata = [0 0];
hasbehavior(double(h),'legend',false);

hax = handle(ax);
props = [findprop(hax,'XLim'),findprop(hax,'YLim')];
l = handle.listener(hax,props,'PropertyPostSet',{@doLimAction,h});
h.listener = l;

function doLimAction(hSrc,eventData,h)
hax = eventData.affectedObject;
if strcmp(h.Orientation,'X')
  set(h,'XData',get(hax,'XLim'),'YData',[h.BaseValue h.BaseValue]);
else
  set(h,'YData',get(hax,'YLim'),'XData',[h.BaseValue h.BaseValue]);
end