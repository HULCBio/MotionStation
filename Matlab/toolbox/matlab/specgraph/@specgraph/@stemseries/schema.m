function schema()
%SCHEMA Stem series schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('graph2d'); 
seriesCls = basePkg.findclass('series');

%define class
hClass = schema.class(classPkg , 'stemseries', seriesCls);
hClass.description = 'A stem plot of a vector of data';

%initialize listener lists
l = [];
base = [];
ch = [];
ch1 = [];
ch2 = [];
codeProp = [];

hProp = schema.prop(hClass,'MarkerHandle','handle');
hProp.visible = 'off';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass,'StemHandle','handle');
hProp.visible = 'off';
hProp.AccessFlags.Serialize = 'off';

hProp = schema.prop(hClass, 'BaseValue', 'double');
hProp.Description = 'Base line value';
hProp.FactoryValue = 0.0;
base = Lappend(base,hProp);

hProp = schema.prop(hClass, 'BaseLine', 'double');
hProp.Description = 'Handle to baseline';

hProp = schema.prop(hClass, 'Color', 'lineColorType');
hProp.Description = 'Line color';
hProp.FactoryValue = [0 0 0];
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
ch1 = Lappend(ch1,hProp);
codeProp = Lappend(codeProp,hProp);

hProp = schema.prop(hClass, 'CodeGenLineStyleMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'Marker', 'lineMarkerType');
hProp.Description = 'Marker symbol';
hProp.FactoryValue = 'o';
ch2 = Lappend(ch2,hProp);
codeProp = Lappend(codeProp,hProp);

hProp = schema.prop(hClass, 'CodeGenMarkerMode', 'axesXLimModeType');
hProp.FactoryValue = 'auto';
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'MarkerEdgeColor', 'lineMarkerEdgeColorType');
hProp.Description = 'Marker edge color';
hProp.FactoryValue = 'auto';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
			      @LdoEdgeColorAction));

hProp = schema.prop(hClass, 'MarkerFaceColor', 'lineMarkerFaceColorType');
hProp.Description = 'Marker face color';
hProp.FactoryValue = 'none';
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
			      @LdoFaceColorAction));

hProp = schema.prop(hClass, 'MarkerSize', 'lineMarkerSizeType');
hProp.Description = 'Marker size';
hProp.FactoryValue = 6;
ch2 = Lappend(ch2,hProp);

hProp = schema.prop(hClass, 'ShowBaseLine', 'on/off');
hProp.Description = 'Show baseline of bars';
hProp.FactoryValue = 'on';
base = Lappend(base,hProp);

% SwitchProps is used by changeseriestype.m
hProp = schema.prop(hClass, 'SwitchProps', 'string vector');
hProp.FactoryValue = {'LineWidth','LineStyle','Color',...
                    'MarkerEdgeColor','MarkerFaceColor','Marker',...
                    'MarkerSize','DisplayName','Visible',...
                    'BaseValue','ShowBaseLine'};
hProp.Visible = 'off';

l = Lappend(l,handle.listener(hClass, base, 'PropertyPostSet',...
			      @LdoUpdateBaselineAction));
l = Lappend(l,handle.listener(hClass, ch, 'PropertyPostSet',...
			      @LdoUpdateChildrenAction));l = Lappend(l,handle.listener(hClass, ch1, 'PropertyPostSet',...
			      @LdoUpdateChildLineAction));
l = Lappend(l,handle.listener(hClass, ch2, 'PropertyPostSet',...
			      @LdoUpdateChildMarkerAction));

% ToDo: Put ZData on series object?
hProp = schema.prop(hClass,'ZDataSource','string');
hProp.Description = 'ZData source';

hProp = schema.prop(hClass,'ZData','NReals');
hProp.Description = 'Dependent variable';
hProp.FactoryValue = [];
l = Lappend(l,handle.listener(hClass, hProp, 'PropertyPostSet',...
			      @LdoUpdateAction));

hProp = findprop(seriesCls,'YData');
l = Lappend(l,handle.listener(seriesCls, hProp, 'PropertyPostSet',...
			      @LdoUpdateAction));
hProp = findprop(seriesCls,'XData');
l = Lappend(l,handle.listener(seriesCls, hProp, 'PropertyPostSet',...
			      @LdoUpdateXDataAction));
l = Lappend(l,handle.listener(hClass,codeProp,'PropertyPreSet',@LdoSetManualCodeModeAction));

hProp = schema.prop(hClass, 'BaseLineListener', 'handle vector');
hProp.Visible = 'off';

%store class listeners - need to destroy manually
setappdata(0,'SpecgraphStemListeners',l);

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
  if strcmpi(prop,'color') && ...
	strcmpi(h.markerfacecolor,'auto') && ...
	strcmpi(h.markeredgecolor,'auto')
    LdoFaceColorAction(hSrc, eventData);
  end
  setLegendInfo(h);
end

function LdoUpdateChildLineAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  hStem = get(h,'StemHandle');
  set(hStem,prop,get(h,prop))
  setLegendInfo(h);
end

function LdoUpdateChildMarkerAction(hSrc, eventData)
h = eventData.affectedObject;
if h.initialized
  prop = hSrc.name;
  hMarker = get(h,'MarkerHandle');
  set(hMarker,prop,get(h,prop))
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
  % Don't update baseline in 3-D 
  is3D = ~isempty(h.ZData);
  if ~is3D && ishandle(h.baseline)
    set(h.baseline,'BaseValue',h.BaseValue);
    set(h.baseline,'Visible',h.ShowBaseLine);
  end
  h.dirty = 'invalid';
end

function LdoFaceColorAction(hSrc,eventData)
h = eventData.affectedObject;
if h.initialized
  c = h.markerfacecolor;
  hMarker = get(h,'MarkerHandle');
  hStem = get(h,'StemHandle');
  if strcmp(c,'auto')
    edge = get(h,'markeredgecolor');
    if strcmp(edge,'auto')
      edge = get(hStem,'color');
    end
    set(hMarker,'markerfacecolor',edge);
  else
    set(hMarker,'markerfacecolor',c);
  end
  setLegendInfo(h);
end
    
function LdoEdgeColorAction(hSrc,eventData)
h = eventData.affectedObject;
if h.initialized
  if strcmp(h.markerfacecolor,'auto')
    LdoFaceColorAction(hSrc,eventData);
  end
  LdoUpdateChildMarkerAction(hSrc,eventData);
end
    
