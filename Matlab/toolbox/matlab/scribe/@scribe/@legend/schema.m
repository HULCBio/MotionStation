function schema()
%SCHEMA defines the scribe.LEGEND schema
%
%  See also PLOTEDIT

%   Copyright 1984-2004 The MathWorks, Inc.
%   $ $  $  $

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'legend', hgPk.findclass('axes'));
if isempty(findtype('LegendLocationPreset'))
  schema.EnumType('LegendLocationPreset',{...
      'North','South','East','West',...
      'NorthEast','SouthEast','NorthWest','SouthWest',...
      'NorthOutside','SouthOutside',...
      'EastOutside','WestOutside',...
      'NorthEastOutside','SouthEastOutside',...
      'NorthWestOutside','SouthWestOutside',...
      'Best','BestOutside',...
      'none'});
end
if isempty(findtype('LegendUnits'))
    schema.EnumType('LegendUnits',{'normalized','pixels'});
end
if isempty(findtype('LegendOrientation'))
    schema.EnumType('LegendOrientation',{'horizontal','vertical'});
end
if isempty(findtype('LegendTextLocation'))
    schema.EnumType('LegendTextLocation',{'left','right','top','bottom'});
end

p = schema.event(h,'LegendInfoChanged');
p = schema.event(h,'LegendConstructorDone');

p = schema.prop(h,'Ready','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';

% end of common properties

% LegendInfoChildren is on if PlotChildren are legendinfo objects rather
% than hg objects.
p = schema.prop(h,'LegendInfoChildren','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible='off';

p = schema.prop(h,'PlotChildListen','on/off');
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'on';
p.Visible='off';

% for possible legend background
p = schema.prop(h,'Image','MATLAB array');
p.AccessFlags.Init = 'on';
p.FactoryValue = [];
p.Visible = 'off';

p = schema.prop(h,'ObservePos','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'on';
p.Visible='off';

p = schema.prop(h,'Location','LegendLocationPreset');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'NorthEast';

p = schema.prop(h,'Orientation','LegendOrientation');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'vertical';

p = schema.prop(h,'ItemTextLocation','LegendTextLocation');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'left';
p.Visible = 'off';

%width,height of item patches,lines (largest in size sublegend) in points
p = schema.prop(h,'ItemTokenSize','NReals');
p.AccessFlags.Init = 'on';
p.FactoryValue = [30,18];
p.Visible = 'off';

% delete proxy for peer axes
p = schema.prop(h,'DeleteProxy','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% COMPONENTS
% peer axes
p = schema.prop(h,'Axes','handle');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = [];
p.Visible='off';

% handle vector to plot lines surfs and patches
p = schema.prop(h,'Plotchildren','handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = [];
p.Visible='off';
% item patches and lines patches
p = schema.prop(h,'ItemTokens','handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = [];
p.Visible='off';
% line text
p = schema.prop(h,'ItemText','handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = [];
p.Visible='off';

% show style sublegend (default)
p = schema.prop(h,'StyleLegend','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'on';
p.Visible='off';

% STYLE PROPERTIES
p = schema.prop(h,'ObserveStyle','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'on';
p.Visible='off';

p = schema.prop(h,'EdgeColor','axesColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultAxesXColor');

% ITEM TEXT PROPERTIES
p = schema.prop(h,'ObserveText','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'on';
p.Visible='off';

p = schema.prop(h,'TextColor','textColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultTextColor');

p = schema.prop(h,'Interpreter','textInterpreterType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultTextInterpreter');

p = schema.prop(h,'TextEditing','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible='off';

% Strings should really be NStrings but we want to allow multi-line
% legend entries and so it is a generic MATLAB array.
p = schema.prop(h,'String','MATLAB array');
p.AccessFlags.Init = 'on';
p.FactoryValue = {};

% LEGEND TITLE TEXT PROPERTIES (TBD)

% LEGEND FOOTNOTE TEXT PROPERTIES (TBD)

% LEGEND LISTENERS

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicSet = 'off';
pl.Visible='off';

pl = schema.prop(h, 'DeleteListener', 'handle');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
pl.Visible='off';