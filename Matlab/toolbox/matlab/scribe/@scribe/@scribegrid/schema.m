function schema
%SCHEMA defines the scribe.SCRIBEGRID schema
%
%  See also PLOTEDIT

%   Copyright 1984-2003 The MathWorks, Inc.
%   $  $  $  $

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'scribegrid', hgPk.findclass('hggroup'));

p = schema.prop(h,'ScribeUAxes','handle');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(h,'ShapeType','ScribeShapeType');
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'scribegrid';

p = schema.prop(h,'Index','int32');
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 0;

p = schema.prop(h,'MoveMode','int32');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 0;

p = schema.prop(h,'Selected','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';

% end of common properties
p = schema.prop(h,'Color','NReals');
p.AccessFlags.Init = 'on';
p.FactoryValue = [0 0 0];

p = schema.prop(h,'LineWidth','double');
p.AccessFlags.Init = 'on';
p.FactoryValue = 1.0;

p = schema.prop(h,'LineStyle','string');
p.AccessFlags.Init = 'on';
p.FactoryValue = '-';

p = schema.prop(h,'Xspace','double');
p.AccessFlags.Init = 'on';
p.FactoryValue = 20.0;

p = schema.prop(h,'Yspace','double');
p.AccessFlags.Init = 'on';
p.FactoryValue = 20.0;

p = schema.prop(h,'ObservePos','on/off');
p = schema.prop(h,'ObserveStyle','on/off');

p = schema.prop(h,'Visible','on/off');
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';

p = schema.prop(h,'PrintVisibleTemporary','on/off');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'Units','string');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'pixels';

p = schema.prop(h,'Vlines','handle vector');
p = schema.prop(h,'Hlines','handle vector');

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';