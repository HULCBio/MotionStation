function schema()
%SCHEMA Contour schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('hg');

%define class
hClass = schema.class(classPkg , 'contourgroup', basePkg.findclass('hggroup'));
hClass.description = 'A 2D contour plot of a matrix of data';

%init lists of properties for various listeners
listeners = [];
modeProp = [];
markDirtyProp = [];
shortDirtyProp = [];
modeSwitchProp = [];
setChildProp = [];
setColorProp = [];

%define properties
hProp = schema.prop(hClass, 'Dirty', 'ChartDirtyEnum');
hProp.FactoryValue = 'clean';
hProp.Visible = 'off';

hProp2 = schema.prop(hClass, 'RefreshMode', 'axesXLimModeType');
hProp2.FactoryValue = 'manual';
hProp2.Visible = 'off';

%always put dirty listener first in list
l = handle.listener(hClass, [hProp hProp2], 'PropertyPostSet',...
		    @LdoDirtyAction);
listeners = Lappend(listeners,l);

hProp = schema.prop(hClass, 'ContourMatrix', 'MATLAB array');
hProp.Description = 'Contour matrix';
hProp.AccessFlags.PublicSet = 'off';

% Color is hidden because we want people to start using LineColor
hProp = schema.prop(hClass, 'Color', 'lineColorType');
hProp.Description = 'Line color';
hProp.FactoryValue = [0 0 0];
hProp.Visible = 'off';
setColorProp = Lappend(setColorProp,hProp);

hProp = schema.prop(hClass, 'DisplayName', 'string');
hProp.Description = 'Name use for displays and legends';

% EdgeColor is hidden because we want people to start using LineColor
hProp = schema.prop(hClass, 'EdgeColor', 'MATLAB array');
hProp.Description = 'Line color';hProp.FactoryValue = 'flat';
hProp.Visible = 'off';
setColorProp = Lappend(setColorProp,hProp);

hProp = schema.prop(hClass, 'Fill', 'on/off');
hProp.FactoryValue ='off';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'LabelSpacing', 'double');
hProp.Description = 'Space in points between labels on a level curve';
hProp.FactoryValue = 144;
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'LevelList', 'NReals');
hProp.Description = 'Array of contour levels';
modeProp = Lappend(modeProp,hProp);
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'LevelListMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
modeSwitchProp = Lappend(modeSwitchProp,hProp);

hProp = schema.prop(hClass, 'LevelStep', 'double');
modeProp = Lappend(modeProp,hProp);
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'LevelStepMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
modeSwitchProp = Lappend(modeSwitchProp,hProp);

hProp = schema.prop(hClass, 'LineColor', 'lineMarkerEdgeColorType');
hProp.Description = 'Color for contour lines';
hProp.FactoryValue = 'auto';
setColorProp = Lappend(setColorProp,hProp);

hProp = schema.prop(hClass, 'LineStyle', 'lineLineStyleType');
hProp.FactoryValue = '-';
setChildProp = Lappend(setChildProp,hProp);

hProp = schema.prop(hClass, 'LineWidth', 'double');
hProp.FactoryValue = 0.5;
setChildProp = Lappend(setChildProp,hProp);

hProp = schema.prop(hClass, 'ShowText', 'on/off');
hProp.Description = 'Show text label';
shortDirtyProp = Lappend(shortDirtyProp,hProp);

hProp = schema.prop(hClass, 'TextList', 'NReals');
hProp.Description = 'Array of contour levels with text labels';
modeProp = Lappend(modeProp,hProp);
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'TextListMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
modeSwitchProp = Lappend(modeSwitchProp,hProp);

hProp = schema.prop(hClass, 'TextStep', 'double');
modeProp = Lappend(modeProp,hProp);
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'TextStepMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
modeSwitchProp = Lappend(modeSwitchProp,hProp);

hProp = schema.prop(hClass, 'UseAxesColorOrder', 'on/off');
hProp.Description = 'Use axes color order instead of colormap or constant';
hProp.Visible = 'off';
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
hProp.Description = 'Data to plot';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'ZDataSource', 'string');
hProp.Description = 'Contour data source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'Initialized', 'double');
hProp.FactoryValue = false;
hProp.Visible = 'off';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'CDataMapping', 'patchCDataMappingType');
hProp.FactoryValue = 'scaled';
hProp.Visible = 'off';

l=handle.listener(hClass,modeSwitchProp,'PropertyPostSet',@LdoModeSwitchAction);
listeners = Lappend(listeners,l);
l=handle.listener(hClass,markDirtyProp,'PropertyPostSet',@LdoMarkDirtyAction);
listeners = Lappend(listeners,l);
l=handle.listener(hClass,setChildProp,'PropertyPostSet',@LdoUpdateChildrenAction);
listeners = Lappend(listeners,l);
l=handle.listener(hClass,setColorProp,'PropertyPostSet',@LdoUpdateColorAction);
listeners = Lappend(listeners,l);
l=handle.listener(hClass,shortDirtyProp,'PropertyPostSet',@LdoShortDirtyAction);
listeners = Lappend(listeners,l);
l=handle.listener(hClass,modeProp,'PropertyPreSet',@LdoSetManualModeAction);
listeners = Lappend(listeners,l);

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphContourListeners',listeners);

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
  setLegendInfo(h);
end

function LdoUpdateColorAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  list = getappdata(0,'SpecgraphContourListeners');
  set(list,'enable','off');
  newval = get(h,prop);
  if strcmp(prop,'EdgeColor')
    if ischar(newval) && any(strcmp(newval,{'flat','interp'}))
      h.linecolor = 'auto';
    else
      h.linecolor = newval;
      h.color = newval;
    end
  elseif strcmp(prop,'Color')
    h.linecolor = newval;
    h.edgecolor = newval;
  else
    if ischar(newval) && strcmpi(newval(1),'a')
      h.edgecolor = 'flat';
    else
      h.color = newval;
      h.edgecolor = newval;
    end
  end
  ch = findobj(double(h),'type','patch');
  set(ch,'edgecolor', h.edgecolor)
  set(list,'enable','on');
  setLegendInfo(h);
end

function LdoMarkDirtyAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  setContourMatrix(h,[]); % force new contour matrix computation
  h.dirty = 'invalid';
end

function LdoShortDirtyAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  h.dirty = 'invalid';
end

function LdoDirtyAction(hSrc, eventData)
h = eventData.affectedObject;
if strcmp(h.refreshmode,'auto') && h.initialized
  refresh(h);
end

