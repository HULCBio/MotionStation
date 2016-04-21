function h = barseries(varargin)
%BARSERIES barseries constructor
%  H = BARSERIES(PARAM1, VALUE1, PARAM2, VALUE2, ...) creates
%  a barseries in the current axes with given param-value pairs.
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
h = specgraph.barseries('parent',parent);
h.initialized = 1;
parentType = get(parent,'Type');
parentAxes = parent;
% only call ancestor if needed for performance
if ~strcmp(parentType,'axes')
  parentAxes = ancestor(parent,'axes');
end
edgec = get(parentAxes,'xcolor');
p = patch('xdata',[0 0 1 1],'ydata',[0 1 1 0],'cdata',[0 1 2 3],...
	  'hittest','off',...
	  'FaceColor','flat','EdgeColor',edgec,...
	  'parent',double(h));

% find existing baseline, if any
dbaseline = getappdata(parent,'SeriesBaseLine');
if isempty(dbaseline) || ~ishandle(dbaseline)
  baseline = specgraph.baseline('parent',double(parent));
  dbaseline = double(baseline);
  set(baseline,'handlevisibility','off');
  setappdata(parent,'SeriesBaseLine',dbaseline);
else
  baseline = handle(dbaseline);
end
h.baseline = dbaseline;

l1 = handle.listener(baseline,...
                     baseline.findprop('BaseValue'),...
                     'PropertyPostSet',{@LdoBaseLineChanged,h});
l2 = handle.listener(baseline,...
                     baseline.findprop('Visible'),...
                     'PropertyPostSet',{@LdoBaseLineChanged,h});
h.baselineListener = [l1 l2];
h.basevalue = get(baseline,'BaseValue');
if ~isempty(args)
  set(h,args{:})
end
setappdata(double(h),'LegendLegendInfo',[]);

fig = handle(get(parent,'Parent'));
% only call ancestor if needed for performance
if ~strcmp(get(fig,'Type'),'figure')
  fig = handle(ancestor(fig,'figure'));
end
ax = handle(parentAxes);
fprop = findprop(fig,'Colormap');
aprop = findprop(ax,'CLim');
hprop = findprop(h,'FaceColor');
list = handle.listener(fig,fprop,'PropertyPostSet',{@LdoColorChanged,h});
list(2) = handle.listener(ax,aprop,'PropertyPostSet',{@LdoColorChanged,h});
list(3) = handle.listener(h,hprop,'PropertyPostSet',{@LdoColorChanged,h});
setappdata(double(h),'barcolorlistener',list);
list = handle.listener(h,'ObjectBeingDestroyed',@LdestroyBaseLine);
setappdata(double(h),'StemDestroyedListener',list);

function LdoColorChanged(hSrc, eventData, h)
fig = get(get(h,'Parent'),'Parent');
% only call ancestor if needed for performance
if ~strcmp(get(fig,'Type'),'figure')
  fig = ancestor(fig,'figure');
end
if ~isappdata(fig,'PlotManager')
  return;
end
if ishandle(h) && length(get(h,'Children')) == 1
  color = get(h,'FaceColor');
  if ischar(color)
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
  evdata = specgraph.colorevent(h,'BarColorChanged');
  set(evdata,'newValue',color);
  send(h,'BarColorChanged',evdata);
end

function LdoBaseLineChanged(hSrc, eventData, h)
baseline = eventData.affectedObject;
set(h,'BaseValue',get(baseline,'BaseValue'));
set(h,'ShowBaseLine',get(baseline,'Visible'));

function LdestroyBaseLine(hSrc, eventData)
if ishandle(hSrc)
  parent = handle(get(hSrc,'Parent'));
  if strcmp(get(parent,'BeingDeleted'),'off')
    baseline = hSrc.BaseLine;
    if ishandle(baseline)
      peers = find(parent,'BaseLine',baseline);
      if isequal(peers,hSrc)
        delete(baseline);
      end
    end
  end
end
