function schema()
%SCHEMA Quiver schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('hg');

%define class
hClass = schema.class(classPkg , 'quivergroup', basePkg.findclass('hggroup'));
hClass.description = 'A 2D quiver plot of matrices of u,v data';

%init lists of properties for various listeners
l = [];
modeProp = [];
codeProp = [];
markDirtyProp = [];
modeSwitchProp = [];
setChildProp = [];
setBaseProp = [];
setArrowProp = [];

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

hProp = schema.prop(hClass, 'AutoScale', 'on/off');
hProp.Description = 'scale arrow length automatically';
hProp.factoryValue = 'on';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'AutoScaleFactor', 'double');
hProp.Description = 'autoscale length factor';
hProp.factoryValue = .9;
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'Color', 'lineColorType');
hProp.Description = 'Arrow color';
hProp.factoryValue = [0 0 0];
setChildProp = Lappend(setChildProp,hProp);
codeProp = Lappend(codeProp,hProp);

hProp = schema.prop(hClass, 'CodeGenColorMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'DisplayName', 'string');
hProp.Description = 'Name use for displays and legends';

hProp = schema.prop(hClass, 'LineStyle', 'lineLineStyleType');
hProp.factoryValue = '-';
hProp.Description = 'Base line style';
setArrowProp = Lappend(setArrowProp,hProp);

hProp = schema.prop(hClass, 'LineWidth', 'double');
hProp.Description = 'Base line width';
hProp.factoryValue = 0.5;
setChildProp = Lappend(setChildProp,hProp);

hProp = schema.prop(hClass, 'Marker', 'lineMarkerType');
hProp.Description = 'Symbol for vector base point';
hProp.factoryValue = 'none';
setBaseProp = Lappend(setBaseProp,hProp);

hProp = schema.prop(hClass, 'MarkerFaceColor','lineMarkerFaceColorType');
hProp.Description = 'Marker face color';
hProp.factoryValue = 'none';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
			      @LdoFaceColorAction));
%setChildProp = Lappend(setBaseProp,hProp);

hProp = schema.prop(hClass, 'MarkerEdgeColor','lineMarkerEdgeColorType');
hProp.Description = 'Marker edge color';
hProp.factoryValue = 'auto';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
			      @LdoEdgeColorAction));
%setChildProp = Lappend(setBaseProp,hProp);

hProp = schema.prop(hClass, 'MarkerSize', 'double');
hProp.factoryValue = 6;
setBaseProp = Lappend(setBaseProp,hProp);

hProp = schema.prop(hClass, 'MaxHeadSize', 'double');
hProp.Description = 'Maximum relative arrow head length';
hProp.factoryValue = 0.2;

hProp = schema.prop(hClass, 'ShowArrowHead', 'on/off');
hProp.Description = 'Draw arrow head';
hProp.factoryValue = 'on';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'XData', 'MATLAB array');
hProp.Description = 'X data coordinates';
modeProp = Lappend(modeProp,hProp);
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'XDataMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
modeSwitchProp = Lappend(modeSwitchProp,hProp);

hProp = schema.prop(hClass, 'XDataSource', 'string');
hProp.Description = 'X variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'YData', 'MATLAB array');
hProp.Description = 'Y data coordinates';
modeProp = Lappend(modeProp,hProp);
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'YDataMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
modeSwitchProp = Lappend(modeSwitchProp,hProp);

hProp = schema.prop(hClass, 'YDataSource', 'string');
hProp.Description = 'Y variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'ZData', 'MATLAB array');
hProp.Description = 'Z data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'ZDataSource', 'string');
hProp.Description = 'Z variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'UData', 'MATLAB array');
hProp.Description = 'U data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'UDataSource', 'string');
hProp.Description = 'U variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'VData', 'MATLAB array');
hProp.Description = 'V data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'VDataSource', 'string');
hProp.Description = 'V variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'WData', 'MATLAB array');
hProp.Description = 'W data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'WDataSource', 'string');
hProp.Description = 'W variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'Initialized', 'double');
hProp.FactoryValue = 0;
hProp.Visible = 'off';
hProp.AccessFlags.Serialize = 'off';

l = Lappend(l,handle.listener(hClass,modeSwitchProp,'PropertyPostSet',@LdoModeSwitchAction));
l = Lappend(l,handle.listener(hClass,markDirtyProp,'PropertyPostSet',@LdoMarkDirtyAction));
l = Lappend(l,handle.listener(hClass,setChildProp,'PropertyPostSet',@LdoUpdateChildrenAction));
l = Lappend(l,handle.listener(hClass,setBaseProp,'PropertyPostSet',@LdoUpdateBaseAction));
l = Lappend(l,handle.listener(hClass,setArrowProp,'PropertyPostSet',@LdoUpdateArrowAction));
l = Lappend(l,handle.listener(hClass,codeProp,'PropertyPreSet',...
                              @LdoSetManualCodeModeAction));
l = Lappend(l,handle.listener(hClass,modeProp,'PropertyPreSet',...
                              @LdoSetManualModeAction)); 

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphQuiverListeners',l);

function out = Lappend(in,data)
if isempty(in)
  out = data;
else
  out = [in data];
end

%%%% Listener callbacks  %%%%

function LdoSetManualModeAction(hSrc, eventData)
h = eventData.affectedObject;
prop = hSrc.name;
set(h,[prop 'Mode'],'manual');

function LdoSetManualCodeModeAction(hSrc, eventData)
h = eventData.affectedObject;
prop = hSrc.name;
set(h,['CodeGen' prop 'Mode'],'manual');

function LdoModeSwitchAction(hSrc, eventData)
h = eventData.affectedObject;
modeprop = hSrc.name;
if strcmp(get(h,modeprop),'auto') && h.initialized
  h.dirty = 'invalid';
end

function LdoUpdateChildrenAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  set(findobj(double(h),'type','patch'),prop,get(h,prop))
  set(findobj(double(h),'type','line'),prop,get(h,prop))
  if strcmp(h.markerfacecolor,'auto')
    LdoFaceColorAction(hSrc,eventData);
  end
  setLegendInfo(h);
end

function LdoUpdateBaseAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  ch = get(h,'children');
  set(ch(3),prop,get(h,prop))
  setLegendInfo(h);
end

function LdoUpdateArrowAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  ch = get(h,'children');
  set(ch(1:2),prop,get(h,prop))
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

function LdoFaceColorAction(hSrc,eventData)
h = eventData.affectedObject;
if h.initialized
  c = h.markerfacecolor;
  ch = get(h,'children');
  if strcmp(c,'auto')
    edge = get(h,'markeredgecolor');
    if strcmp(edge,'auto')
      edge = get(h,'color');
    end
    set(ch(3),'markerfacecolor',edge);
  else
    set(ch(3),'markerfacecolor',c);
  end
end
    
function LdoEdgeColorAction(hSrc,eventData)
h = eventData.affectedObject;
if h.initialized
  if strcmp(h.markerfacecolor,'auto')
    LdoFaceColorAction(hSrc,eventData);
  end
  LdoUpdateBaseAction(hSrc,eventData);
end
