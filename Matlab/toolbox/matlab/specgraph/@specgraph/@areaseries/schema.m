function schema()
%SCHEMA Area series schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('graph2d');
seriesCls = basePkg.findclass('series');

%define class
hClass = schema.class(classPkg , 'areaseries', seriesCls);
hClass.description = 'A 2D area plot of a vector of data';

p = schema.event(hClass,'AreaColorChanged');

%initialize listener lists
l = [];
ch = [];
modeProp = [];
modeSwitchProp = [];

%define properties
hProp = schema.prop(hClass, 'BaseValue', 'double');
hProp.Description = 'Base line value';
hProp.FactoryValue = 0.0;
sib = hProp;

hProp = schema.prop(hClass, 'EdgeColor', 'patchEdgeColorType');
hProp.Description = 'Area edge color';
hProp.FactoryValue = [0 0 0];
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'FaceColor', 'patchFaceColorType');
hProp.Description = 'Area face color';
hProp.FactoryValue = 'flat';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'LineStyle', 'patchLineStyleType');
hProp.Description = 'Line style';
hProp.FactoryValue = '-';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'LineWidth', 'double');
hProp.Description = 'Line width in points';
hProp.FactoryValue = 0.5;
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'CDataMapping', 'patchCDataMappingType');
hProp.FactoryValue = 'scaled';
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'AreaPeers', 'handle vector');
hProp.Visible = 'off';

% SwitchProps is used by changeseriestype.m
hProp = schema.prop(hClass, 'SwitchProps', 'string vector');
hProp.FactoryValue = {'EdgeColor','LineWidth','LineStyle','BaseValue',...
                   'FaceColor','DisplayName','Visible'};
hProp.Visible = 'off';

l = Lappend(l,handle.listener(hClass, ch, 'PropertyPostSet',...
			      @LdoUpdateChildrenAction));
l = Lappend(l,handle.listener(hClass, sib, 'PropertyPostSet',...
			      @LdoUpdateSiblingAction));
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

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphAreaListeners',l);

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

function LdoUpdateSiblingAction(hSrc,eventData)
h = eventData.affectedObject;
p = handle(h.parent);
sibs = find(p,'-isa','specgraph.areaseries');
prop = hSrc.name;
oldrefresh = h.RefreshMode;
h.RefreshMode = 'manual';
set(sibs,prop,get(h,prop));
h.Dirty = 'invalid';
h.RefreshMode = oldrefresh;
%work around bug in hggroup where it doesn't update automatically
for k=1:length(sibs)
  update(handle(sibs(k)));
end
