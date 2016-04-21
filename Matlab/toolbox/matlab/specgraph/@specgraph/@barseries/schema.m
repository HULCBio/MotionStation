function schema()
%SCHEMA Bar series schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('graph2d');
seriesCls = basePkg.findclass('series');

%define class
hClass = schema.class(classPkg , 'barseries', seriesCls);
hClass.description = 'A 2D bar plot of a vector of data';

%define data types
if( isempty(findtype('BarLayoutType')) )
	schema.EnumType('BarLayoutType', {'stacked','grouped'});
end

p = schema.event(hClass,'BarColorChanged');

%initialize listener lists
l = [];
base = [];
sib = [];
ch = [];
modeProp = [];
modeSwitchProp = [];

%define properties
hProp = schema.prop(hClass, 'BaseValue', 'double');
hProp.Description = 'Base line value';
hProp.FactoryValue = 0.0;
base = Lappend(base,hProp);

hProp = schema.prop(hClass, 'BaseLine', 'double');
hProp.Description = 'Handle to baseline';

hProp = schema.prop(hClass, 'BarLayout', 'BarLayoutType');
hProp.Description = 'Group or stack bars';
hProp.FactoryValue = 'grouped';
sib = Lappend(sib,hProp);

hProp = schema.prop(hClass, 'BarWidth', 'double');
hProp.Description = 'Width in range [0 1]';
hProp.FactoryValue = 0.8;
sib = Lappend(sib,hProp);

hProp = schema.prop(hClass, 'Horizontal', 'on/off');
hProp.Description = 'Horizontal bars';
hProp.FactoryValue = 'off';
sib = Lappend(sib,hProp);

hProp = schema.prop(hClass, 'LineWidth', 'double');
hProp.Description = 'Line width in points';
hProp.FactoryValue = 0.5;
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'EdgeColor', 'patchEdgeColorType');
hProp.Description = 'Bar edge color';
hProp.FactoryValue = [0 0 0];
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'FaceColor', 'patchFaceColorType');
hProp.Description = 'Bar face color';
hProp.FactoryValue = 'flat';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'LineStyle', 'patchLineStyleType');
hProp.Description = 'Line style';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'ShowBaseLine', 'on/off');
hProp.Description = 'Show baseline of bars';
hProp.FactoryValue = 'on';
base = Lappend(base,hProp);

hProp = schema.prop(hClass, 'CDataMapping', 'patchCDataMappingType');
hProp.FactoryValue = 'scaled';
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'BarPeers', 'handle vector');
hProp.Visible = 'off';

% SwitchProps is used by changeseriestype.m
hProp = schema.prop(hClass, 'SwitchProps', 'string vector');
hProp.FactoryValue = {'EdgeColor','BarLayout','BarWidth',...
		    'LineWidth','LineStyle','BaseValue','ShowBaseLine'};
hProp.Visible = 'off';

l = Lappend(l,handle.listener(hClass, base, 'PropertyPostSet',...
			      @LdoUpdateBaselineAction));
l = Lappend(l,handle.listener(hClass, sib, 'PropertyPostSet',...
			      @LdoUpdateSiblingAction));
l = Lappend(l,handle.listener(hClass, ch, 'PropertyPostSet',...
			      @LdoUpdateChildrenAction));
l = Lappend(l,handle.listener(hClass,modeSwitchProp,'PropertyPostSet',...
                              @LdoModeSwitchAction));
l = Lappend(l,handle.listener(hClass,modeProp,'PropertyPreSet',...
                              @LdoSetManualModeAction));

hProp = findprop(seriesCls,'YData');
l = Lappend(l,handle.listener(seriesCls, hProp, 'PropertyPostSet',...
			      @LdoUpdateAction));
hProp = findprop(seriesCls,'XData');
l = Lappend(l,handle.listener(seriesCls, hProp, 'PropertyPostSet',...
			      @LdoUpdateXDataAction));

hProp = schema.prop(hClass, 'BaseLineListener', 'handle vector');
hProp.Visible = 'off';

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphBarListeners',l);

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
  set(get(h,'children'),prop,get(h,prop))
  setLegendInfo(h);
end

function LdoUpdateAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  h.dirty = 'invalid';
end

function LdoUpdateXDataAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized && strcmp(h.xdatamode,'manual')
  h.dirty = 'invalid';
end

function LdoUpdateBaselineAction(hSrc,eventData)
h = eventData.affectedObject;
if h.initialized
  if ishandle(h.baseline)
    set(h.baseline,'BaseValue',h.BaseValue);
    set(h.baseline,'Visible',h.ShowBaseLine);
  end
  h.dirty = 'invalid';
end

function LdoUpdateSiblingAction(hSrc,eventData)
h = eventData.affectedObject;
sibs = find(handle(h.parent),'-isa','specgraph.barseries');
prop = hSrc.name;
if strcmp(prop,'Horizontal')
  if strcmp(h.horizontal,'on')
    setOrientation(handle(h.baseline),'x')
  else
    setOrientation(handle(h.baseline),'y')
  end
end
oldrefresh = h.refreshmode;
h.refreshmode = 'manual';
set(sibs,prop,get(h,prop));
h.dirty = 'invalid';
h.refreshmode = oldrefresh;
%work around bug in hggroup where it doesn't update automatically
for k=1:length(sibs)
  update(handle(sibs(k)));
end
