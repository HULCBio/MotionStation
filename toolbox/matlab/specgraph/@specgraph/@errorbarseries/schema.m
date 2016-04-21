function schema()
%SCHEMA Stair series schema

%   Copyright 1984-2003 The MathWorks, Inc. 


classPkg = findpackage('specgraph');
basePkg = findpackage('hg');
hggroupCls = basePkg.findclass('hggroup');

%define class
hClass = schema.class(classPkg , 'errorbarseries', hggroupCls);
hClass.description = 'A 2D errorbar plot of a vector of data';

%initialize listener lists
l = [];
ch = [];
chbase = [];
modeProp = [];
codeProp = [];
markDirtyProp = [];
modeSwitchProp = [];

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

hProp = schema.prop(hClass, 'Color', 'lineColorType');
hProp.Description = 'Line color';
hProp.FactoryValue = 'k';
ch = Lappend(ch,hProp);
codeProp = Lappend(codeProp,hProp);

hProp = schema.prop(hClass, 'CodeGenColorMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'DisplayName', 'string');
hProp.Description = 'Name use for displays and legends';

hProp = schema.prop(hClass, 'LData', 'MATLAB array');
hProp.Description = 'Lower error data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'LDataSource', 'string');
hProp.Description = 'Lower error variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'LineWidth', 'double');
hProp.Description = 'Line width in points';
hProp.FactoryValue = 0.5;
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'LineStyle', 'patchLineStyleType');
hProp.Description = 'Line style';
chbase = Lappend(chbase,hProp);

hProp = schema.prop(hClass, 'Marker', 'lineMarkerType');
hProp.Description = 'Marker symbol';
hProp.FactoryValue = 'none';
chbase = Lappend(chbase,hProp);

hProp = schema.prop(hClass, 'MarkerEdgeColor', 'lineMarkerEdgeColorType');
hProp.Description = 'Marker edge color';
hProp.FactoryValue = 'auto';
chbase = Lappend(chbase,hProp);

hProp = schema.prop(hClass, 'MarkerFaceColor', 'MATLAB array');
hProp.Description = 'Marker face color';
hProp.FactoryValue = 'none';
chbase = Lappend(chbase,hProp);

hProp = schema.prop(hClass, 'MarkerSize', 'lineMarkerSizeType');
hProp.Description = 'Marker size';
hProp.FactoryValue = 6;
chbase = Lappend(chbase,hProp);

hProp = schema.prop(hClass, 'XData', 'MATLAB array');
hProp.Description = 'X data coordinates';
modeProp = Lappend(modeProp,hProp);
markDirtyProp = Lappend(markDirtyProp,hProp);
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
			      @LdoUpdateXDataAction));

hProp = schema.prop(hClass, 'XDataMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
modeSwitchProp = Lappend(modeSwitchProp,hProp);

hProp = schema.prop(hClass, 'XDataSource', 'string');
hProp.Description = 'X variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'YData', 'MATLAB array');
hProp.Description = 'Y data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
			      @LdoUpdateAction));

hProp = schema.prop(hClass, 'YDataSource', 'string');
hProp.Description = 'Y variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'UData', 'MATLAB array');
hProp.Description = 'Upper error data coordinates';
markDirtyProp = Lappend(markDirtyProp,hProp);

hProp = schema.prop(hClass, 'UDataSource', 'string');
hProp.Description = 'Upper error variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'Initialized', 'double');
hProp.FactoryValue = 0;
hProp.Visible = 'off';
hProp.AccessFlags.Serialize = 'off';

% SwitchProps is used by changeseriestype.m
hProp = schema.prop(hClass, 'SwitchProps', 'string vector');
hProp.FactoryValue = {'LineWidth','LineStyle','Color',...
                    'MarkerEdgeColor','MarkerFaceColor','Marker',...
                    'MarkerSize','DisplayName','Visible'};
hProp.Visible = 'off';

l = Lappend(l,handle.listener(hClass,modeSwitchProp,'PropertyPostSet',@LdoModeSwitchAction));
l = Lappend(l,handle.listener(hClass,markDirtyProp,'PropertyPostSet',@LdoMarkDirtyAction));
l = Lappend(l,handle.listener(hClass, ch, 'PropertyPostSet',...
			      @LdoUpdateChildrenAction));
l = Lappend(l,handle.listener(hClass, chbase, 'PropertyPostSet',...
			      @LdoUpdateBaseAction));
l = Lappend(l,handle.listener(hClass,codeProp,'PropertyPreSet',...
	@LdoSetManualCodeModeAction));
l = Lappend(l,handle.listener(hClass,modeProp,'PropertyPreSet',...
	@LdoSetManualModeAction));

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphErrorbarListeners',l);

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
  set(get(h,'children'),prop,get(h,prop))
  setLegendInfo(h);
end

function LdoUpdateBaseAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  ch = get(h,'children');
  set(ch(1),prop,get(h,prop)) 
  setLegendInfo(h);
end

function LsetXDataSilently(h,value)
% turn off xdatamode listener before setting xdata
listeners = getappdata(0,'SpecgraphErrorbarListeners');
% actually turn off all listeners temporarily
set(listeners,'enable','off');
h.xdata = 1:length(value);
set(listeners,'enable','on');
  
function LdoUpdateAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  if strcmp(h.xdatamode,'auto')
    LsetXDataSilently(h,h.ydata);
  end
  h.dirty = 'invalid';
end

function LdoUpdateXDataAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized && strcmp(h.xdatamode,'manual')
  h.dirty = 'invalid';
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

    
