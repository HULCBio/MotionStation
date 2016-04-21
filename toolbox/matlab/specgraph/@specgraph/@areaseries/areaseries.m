function h = areaseries(varargin)
%AREASERIES areaseries constructor
%  H = AREASERIES(PARAM1, VALUE1, PARAM2, VALUE2, ...) creates
%  an areaseries in the current axes with given param-value pairs.
%  This function is an internal helper function for Handle Graphics
%  and shouldn't be called directly.
  
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
h = specgraph.areaseries('parent',parent);
h.initialized = 1;
edgec = get(ancestor(parent,'axes'),'xcolor');
p=patch('xdata',[0 0 1 1],'ydata',[0 1 1 0],'cdata',[0 1 2 3],...
	'hittest','off',...
	'FaceColor','flat','EdgeColor',edgec,...
	'parent',double(h));
if ~isempty(args)
  set(h,args{:})
end
setLegendInfo(h);

fig = handle(ancestor(h,'figure'));
ax = handle(ancestor(h,'axes'));
fprop = findprop(fig,'Colormap');
aprop = findprop(ax,'CLim');
hprop = findprop(h,'FaceColor');
list = handle.listener(fig,fprop,'PropertyPostSet',{@LdoColorChanged,h});
list(2) = handle.listener(ax,aprop,'PropertyPostSet',{@LdoColorChanged,h});
list(3) = handle.listener(h,hprop,'PropertyPostSet',{@LdoColorChanged,h});
setappdata(double(h),'areacolorlistener',list);

function LdoColorChanged(hSrc, eventData, h)
if ishandle(h) && length(get(h,'Children')) == 1
  color = get(h,'FaceColor');
  if ischar(color)
    fig = ancestor(h,'figure');
    ax = ancestor(h,'axes');
    cmap = get(fig,'Colormap');
    if isempty(cmap), return; end
    clim = get(ax,'CLim');
    fvdata = get(get(h,'children'),'FaceVertexCData');
    seriesnum = fvdata(1);
    color = (seriesnum-clim(1))/(clim(2)-clim(1));
    ind = max(1,min(size(cmap,1),floor(1+color*size(cmap,1))));
    color = cmap(ind,:);
  end
  evdata = specgraph.colorevent(h,'AreaColorChanged');
  set(evdata,'newValue',color);
  send(h,'AreaColorChanged',evdata);
end
