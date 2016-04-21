function schema
%SCHEMA defines the SCRIBE.SCRIBEAXES schema
%
%  See also PLOTEDIT

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $  $

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg,'scribeaxes',hgPk.findclass('axes'));

% lastpos used to decide if resize callback should fully fire
p = schema.prop(h,'LastPos','NReals');
p.Visible = 'off';
p = schema.prop(h,'ScribeUAxes','handle');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'SelectedObjects','handle vector');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'Shapes','handle vector');
p.Visible = 'off';

p = schema.prop(h,'CurrentShape','handle');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

% pixel position of last figure current point
p = schema.prop(h,'CurrentPoint','NReals');
p.AccessFlags.Init = 'on';
p.FactoryValue = [0 0];
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'PinMode','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'InteractiveCreateMode','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'MoveOK','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

% click point in move/resize
p = schema.prop(h,'ClickPoint','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'NClickPoint','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

% object(s) moved in current/last move/resize
p = schema.prop(h,'MovedObjects','handle vector');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'MoveSensitivity','int32');
p.AccessFlags.Init = 'on';
p.FactoryValue = 10;
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(h,'ObserveFigChildAdded','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'on';
p.AccessFlags.Serialize = 'off';

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';

pl = schema.prop(h, 'ObjectListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';