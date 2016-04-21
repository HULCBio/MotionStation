function schema
%SCHEMA defines the scribe.ARROW schema
%

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'line', hgPk.findclass('hgtransform'));

% COMMON SCRIBE SHAPE PROPERTIES
% should be in base scribe class
p = schema.prop(h,'ShapeType','ScribeShapeType');
p.AccessFlags.Serialize = 'on'; 
p.AccessFlags.PublicSet = 'off'; 
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'MoveMode','int32');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 0;
p.Visible = 'off';

% Selected shadows the GObject Selected property on purpose so
% that HG doesn't draw the built-in selection handles.
p = schema.prop(h,'Selected','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';

% LINE WIDTH/STYLE 
p = schema.prop(h,'LineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p = schema.prop(h,'PrevLineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p = schema.prop(h,'LineStyle','lineLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineStyle');
% GLOBAL COLOR - setting this sets all colors.
p = schema.prop(h,'Color','lineColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineColor');

% ARROW UNITS
p = schema.prop(h,'Units','string');
p.AccessFlags.Init = 'on'; p.FactoryValue = 'normalized';
p.Visible = 'off';
% ARROW POSITION(Center) - Normal, Pixel, Data
p = schema.prop(h,'X','NReals');
p.AccessFlags.Init = 'on'; p.FactoryValue = [0.1,0.3];
p = schema.prop(h,'Y','NReals');
p.AccessFlags.Init = 'on'; p.FactoryValue = [0.3,0.3];
% POSITION AT START OF LAST MOVE
p = schema.prop(h,'Xlast','NReals');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
p = schema.prop(h,'Ylast','NReals');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
% TRACKING TEXT OBJECTS FOR PINNED POSITIONS
p = schema.prop(h,'Pin','NReals');
p.AccessFlags.Serialize = 'off';
p.Visible='off';
% PARTS
p = schema.prop(h,'Tail','handle');
p.AccessFlags.Serialize = 'off';
p.Visible='off';
p = schema.prop(h,'Srect','handle vector');
p.AccessFlags.Serialize = 'off';
p.Visible='off';
p = schema.prop(h,'Pinrect','NReals');
p.AccessFlags.Serialize = 'off';
p.Visible='off';
% MOVING
p = schema.prop(h,'MoveX0','double');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
p = schema.prop(h,'MoveY0','double');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
% AFFORDANCE (SELECTION HANDLE) SIZE
p = schema.prop(h,'Afsiz','double');
p.AccessFlags.Init = 'on'; p.FactoryValue = 6;
p.AccessFlags.Serialize = 'off';
p.Visible='off';
% LISTENERS
pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off'; pl.AccessFlags.PublicGet = 'off'; pl.AccessFlags.PublicSet = 'off';
pl.Visible='off';
pl = schema.prop(h, 'DeleteListener', 'handle');
pl.AccessFlags.Serialize = 'off'; pl.AccessFlags.PublicGet = 'off'; pl.AccessFlags.PublicSet = 'off';
pl.Visible='off';
% LISTENER CONTROL
p = schema.prop(h,'ObserveStyle','on/off');
p.AccessFlags.Init = 'on'; p.FactoryValue = 'on';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
p = schema.prop(h,'ObservePos','on/off');
p.AccessFlags.Init = 'on'; p.FactoryValue = 'on';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
