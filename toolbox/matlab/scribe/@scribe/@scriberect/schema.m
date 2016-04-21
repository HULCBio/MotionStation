function schema
%SCHEMA defines the scribe.SCRIBERECT schema
%
%  See also PLOTEDIT

%   Copyright 1984-2004 The MathWorks, Inc. 

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'scriberect', hgPk.findclass('hggroup'));

p = schema.prop(h,'ShapeType','ScribeShapeType');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'rectangle';
p.Visible = 'off';

p = schema.prop(h,'MoveMode','int32');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 0;
p.Visible='off';

% Selected shadows the GObject Selected property on purpose so
% that HG doesn't draw the built-in selection handles.
p = schema.prop(h,'Selected','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';

p = schema.prop(h,'Position','axesPositionType');
p.FactoryValue = [.3 .3 .1 .1];

% end of common properties
p = schema.prop(h,'FaceColor','surfaceFaceColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'none';

p = schema.prop(h,'FaceAlpha','NReals');
p.AccessFlags.Init = 'on';
p.FactoryValue = 1.0;

p = schema.prop(h,'Image','MATLAB array');
p.AccessFlags.Init = 'on';
p.AccessFlags.Serialize = 'off';
p.FactoryValue = [];
p.Visible = 'off';

p = schema.prop(h,'LineWidth','double');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineWidth');

p = schema.prop(h,'EdgeColor','surfaceEdgeColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineColor');

p = schema.prop(h,'LineStyle','surfaceLineStyleType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineLineStyle');

p = schema.prop(h,'ObservePos','on/off');
p.AccessFlags.Init = 'on';
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'on';
p.Visible='off';

p = schema.prop(h,'Units','string');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'normalized';
p.Visible='off';

p = schema.prop(h,'PinPosition','real point');
p.AccessFlags.Init = 'on';
p.AccessFlags.Serialize = 'off';
p.FactoryValue = [0 0];
p.Visible = 'off';

% this will be used to track pinned position
p = schema.prop(h,'Pin','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'Rect','handle');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'off';
p.Visible='off';
p = schema.prop(h,'FaceObject','handle'); % for face
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'off';
p.Visible='off';
p = schema.prop(h,'Srect','handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'off';
p.Visible='off';
p = schema.prop(h,'Pinrect','handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'off';
p.Visible='off';

p = schema.prop(h,'MoveX0','double');
p.AccessFlags.Serialize = 'off';
p.Visible='off';
p = schema.prop(h,'MoveY0','double');
p.AccessFlags.Serialize = 'off';
p.Visible='off';

p = schema.prop(h,'Afsiz','double');
p.AccessFlags.Init = 'on';
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 6;
p.Visible='off';

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
p.Visible='off';

pl = schema.prop(h, 'DeleteListener', 'handle');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
pl.Visible = 'off';

pl = schema.prop(h, 'PinListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
p.Visible='off';