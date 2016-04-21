function schema
%SCHEMA defines the scribe.scribepin schema
%

%   Copyright 1984-2003 The MathWorks, Inc.

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'scribepin', hgPk.findclass('text'));

% the object pinned to (optional)
% If not specified then the text Position is the pinned point
p = schema.prop(h,'PinnedObject','handle');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% the annotation being pinned
p = schema.prop(h,'Target','handle');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% enable/disable the pin
p = schema.prop(h,'Enable','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'off';
p.Visible = 'off';

p = schema.prop(h,'Listeners','handle vector');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
