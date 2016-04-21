function schema()
%SCHEMA Stair series schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('graph2d');
seriesCls = basePkg.findclass('series');

%define class
hClass = schema.class(classPkg , 'stairseries', seriesCls);
hClass.description = 'A 2D stair plot of a vector of data';

%initialize listener lists
l = [];
ch = [];
codeProp = [];

%define properties

hProp = schema.prop(hClass, 'Color', 'lineColorType');
hProp.Description = 'Line color';
hProp.FactoryValue = 'k';
ch = Lappend(ch,hProp);
codeProp = Lappend(codeProp,hProp);

hProp = schema.prop(hClass, 'CodeGenColorMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'LineWidth', 'double');
hProp.Description = 'Line width in points';
hProp.FactoryValue = 0.5;
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'LineStyle', 'patchLineStyleType');
hProp.Description = 'Line style';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'Marker', 'lineMarkerType');
hProp.Description = 'Marker symbol';
hProp.FactoryValue = 'none';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'MarkerEdgeColor', 'lineMarkerEdgeColorType');
hProp.Description = 'Marker edge color';
hProp.FactoryValue = 'auto';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'MarkerFaceColor', 'lineMarkerFaceColorType');
hProp.Description = 'Marker face color';
hProp.FactoryValue = 'none';
ch = Lappend(ch,hProp);

hProp = schema.prop(hClass, 'MarkerSize', 'lineMarkerSizeType');
hProp.Description = 'Marker size';
hProp.FactoryValue = 6;
ch = Lappend(ch,hProp);

% SwitchProps is used by changeseriestype.m
hProp = schema.prop(hClass, 'SwitchProps', 'string vector');
hProp.FactoryValue = {'LineWidth','LineStyle','Color',...
                    'MarkerEdgeColor','MarkerFaceColor','Marker',...
                    'MarkerSize','DisplayName','Visible'};
hProp.Visible = 'off';

l = Lappend(l,handle.listener(hClass, ch, 'PropertyPostSet',...
			      @LdoUpdateChildrenAction));
hProp = findprop(seriesCls,'YData');
l = Lappend(l,handle.listener(seriesCls, hProp, 'PropertyPostSet',...
			      @LdoUpdateAction));
hProp = findprop(seriesCls,'XData');
l = Lappend(l,handle.listener(seriesCls, hProp, 'PropertyPostSet',...
			      @LdoUpdateXDataAction));
l = Lappend(l,handle.listener(hClass,codeProp,'PropertyPreSet',@LdoSetManualCodeModeAction));

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphStairsListeners',l);

function out = Lappend(in,data)
if isempty(in)
  out = data;
else
  out = [in data];
end

%%%% Listener callbacks  %%%%

function LdoSetManualCodeModeAction(hSrc, eventData)
h = eventData.affectedObject;
prop = hSrc.name;
set(h,['CodeGen' prop 'Mode'],'manual');

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

    
