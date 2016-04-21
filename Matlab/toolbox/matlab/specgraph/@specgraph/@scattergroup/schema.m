function schema()
%SCHEMA Scatter schema

%   Copyright 1984-2004 The MathWorks, Inc.

classPkg = findpackage('specgraph');
basePkg = findpackage('hg');

%define class
hClass = schema.class(classPkg , 'scattergroup', basePkg.findclass('hggroup'));
hClass.description = 'A 2D scatter plot with varying color and size';

%init lists of properties for various listeners
l = [];
markDirtyProp = [];
setChildProp = [];

%define properties
hProp = schema.prop(hClass, 'Dirty', 'ChartDirtyEnum');
hProp.FactoryValue = 'clean';
hProp.Visible = 'off';

hProp2 = schema.prop(hClass, 'RefreshMode', 'axesXLimModeType');
hProp2.FactoryValue = 'manual';
hProp2.Visible = 'off';
%always put dirty listener first in list
l = Lappend(l,handle.listener(hClass, [hProp hProp2], 'PropertyPostSet',...
			      @LdoDirtyAction));

hProp = schema.prop(hClass, 'CData', 'MATLAB array');
hProp.Description = 'Color data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'CDataSource', 'string');
hProp.Description = 'Color variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'DisplayName', 'string');
hProp.Description = 'Name use for displays and legends';

hProp = schema.prop(hClass, 'Jitter', 'on/off');
hProp.Description = 'Enable/disable jittering';
hProp.FactoryValue = 'off';
hProp.Visible = 'off';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'JitterAmount', 'double');
hProp.Description = 'Maximum amount of jitter';
hProp.FactoryValue = .2;
hProp.Visible = 'off';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'LineWidth', 'lineLineWidthType');
hProp.factoryValue = .5;
setChildProp = Lappend(setChildProp,hProp);

hProp = schema.prop(hClass, 'Marker', 'lineMarkerType');
hProp.factoryValue = 'o';
setChildProp = Lappend(setChildProp,hProp);

hProp = schema.prop(hClass, 'MarkerEdgeColor','patchMarkerEdgeColorType');
hProp.Description = 'Marker edge color';
hProp.factoryValue = 'flat';
setChildProp = Lappend(setChildProp,hProp);
%l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
%			      @LdoEdgeColorAction));

hProp = schema.prop(hClass, 'MarkerFaceColor','patchMarkerFaceColorType');
hProp.Description = 'Marker face color';
hProp.factoryValue = 'none';
setChildProp = Lappend(setChildProp,hProp);
%l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
%			      @LdoFaceColorAction));

hProp = schema.prop(hClass, 'SizeData', 'NReals');
hProp.Description = 'Size data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'SizeDataSource', 'string');
hProp.Description = 'Size variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'XData', 'NReals');
hProp.Description = 'X data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'XDataSource', 'string');
hProp.Description = 'X variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'YData', 'NReals');
hProp.Description = 'Y data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'YDataSource', 'string');
hProp.Description = 'Y variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'ZData', 'NReals');
hProp.FactoryValue = []; % 1-by-0 empty instead of 0-by-0
hProp.Description = 'Z data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'ZDataSource', 'string');
hProp.Description = 'Z variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'Initialized', 'double');
hProp.FactoryValue = 0;
hProp.Visible = 'off';
hProp.AccessFlags.Serialize = 'off';

l = Lappend(l,handle.listener(hClass,markDirtyProp,'PropertyPostSet',@LdoMarkDirtyAction));
l = Lappend(l,handle.listener(hClass,setChildProp,'PropertyPostSet',@LdoUpdateChildrenAction));

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphScatterListeners',l);

function out = Lappend(in,data)
if isempty(in)
  out = data;
else
  out = [in data];
end

%%%% Listener callbacks  %%%%

function LdoUpdateChildrenAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  if (isequal(prop,'MarkerFaceColor') || ...
      isequal(prop,'MarkerEdgeColor')) && ...
        isequal(size(h.cdata),[1 3]) && ...
        ischar(get(h,prop)) && ...
        ~isequal(get(h,prop),'none')
    LdoMarkDirtyAction(hSrc,eventData);
  else    
    set(get(h,'children'),prop,get(h,prop))
  end
  setLegendInfo(h);
end

function LdoMarkDirtyAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  h.dirty = 'invalid';
end

function LdoDirtyAction(hSrc, eventData)
h = eventData.affectedObject;
if strcmp(h.refreshmode,'auto') && h.initialized
  refresh(h);
end

