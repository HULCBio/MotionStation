function schema()
%SCHEMA Series schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('graph2d');
basePkg = findpackage('hg');

%define class
hClass = schema.class(classPkg , 'series', basePkg.findclass('hggroup'));


%init lists of properties for various listeners
l = [];

%define properties
hProp = schema.prop(hClass, 'DisplayName', 'string');
hProp.Description = 'Name use for displays and legends';

hProp = schema.prop(hClass, 'XData', 'NReals');
hProp.Description = 'Independent variable';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPreSet',...
			      @LdoSetManualModeAction));

hProp = schema.prop(hClass, 'XDataMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
  @LdoModeSwitchAction));

hProp = schema.prop(hClass, 'XDataSource', 'string');
hProp.Description = 'Independent variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'YData', 'NReals');
hProp.Description = 'Dependent variable';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPreSet',...
			      @LdoYDataAction));

hProp = schema.prop(hClass, 'YDataSource', 'string');
hProp.Description = 'Dependent variable source';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'OldSwitchProps', 'MATLAB array');
hProp.Visible = 'off';
hProp = schema.prop(hClass, 'OldSwitchVals', 'MATLAB array');
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'Initialized', 'double');
hProp.FactoryValue = 0;
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'Dirty', 'ChartDirtyEnum');
hProp.FactoryValue = 'clean';
hProp.Visible = 'off';

hProp2 = schema.prop(hClass, 'RefreshMode', 'axesXLimModeType');
hProp2.FactoryValue = 'manual';
hProp2.Visible = 'off';

l = Lappend(l,handle.listener(hClass, [hProp hProp2], 'PropertyPostSet',...
			      @LdoDirtyAction));

%store class listeners - need to destroy manually
setappdata(0,'Graph2dSeriesListeners',l);

function out = Lappend(in,data)
if isempty(in)
  out = data;
else
  out = [in data];
end

%%%% Listener callbacks  %%%%

function LsetXDataSilently(h,value)
% turn off xdatamode listener before setting xdata
listeners = getappdata(0,'Graph2dSeriesListeners');
set(listeners(1),'enable','off');
h.xdata = 1:length(value);
set(listeners(1),'enable','on');
  
function LdoYDataAction(hSrc, eventData)
h = eventData.affectedObject;
if strcmp(h.xdatamode,'auto') && h.initialized
  LsetXDataSilently(h,eventData.newvalue);
  h.dirty = 'invalid';
end

function LdoSetManualModeAction(hSrc, eventData)
h = eventData.affectedObject;
prop = hSrc.name;
set(h,[prop 'Mode'],'manual');

function LdoModeSwitchAction(hSrc, eventData)
h = eventData.affectedObject;
modeprop = hSrc.name;
if strcmp(get(h,modeprop),'auto') && h.initialized
  % turn off xdatamode listener before setting xdata
  listeners = getappdata(0,'Graph2dSeriesListeners');
  set(listeners(1),'enable','off');
  h.xdata = 1:length(h.ydata);
  set(listeners(1),'enable','on');
  h.dirty = 'invalid';
end

function LdoDirtyAction(hSrc, eventData)
h = eventData.affectedObject;
if strcmp(h.refreshmode,'auto') && h.initialized
  refresh(h);
end

