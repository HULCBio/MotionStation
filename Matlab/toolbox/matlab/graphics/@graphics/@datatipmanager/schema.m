function schema

% Copyright 2002 The MathWorks, Inc.

% Construct class
pk = findpackage('graphics');
cls = schema.class(pk,'datatipmanager');

% Public Properties
p = schema.prop(cls,'CurrentDatatip','handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PrivateSet = 'on';

p = schema.prop(cls,'DatatipHandles','handle vector'); % stack
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PrivateSet = 'on';

p = schema.prop(cls,'DatatipStringFcn','MATLAB array');
p = schema.prop(cls,'DatatipCreateFcn','MATLAB array');
p = schema.prop(cls,'UIContextMenu','MATLAB array');

% Private Properties
p = schema.prop(cls,'Figure','handle');
p.Visible = 'off';
p = schema.prop(cls,'Listeners','handle vector');
p.Visible = 'off';

% ...for debugging
p = schema.prop(cls,'Debug','double');
p.FactoryValue = logical(0);
p.Visible = 'off';

% Events
schema.event(cls,'UpdateDatatip');

% Methods
