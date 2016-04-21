function schema

% Copyright 2003 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'linkprop');

% Property for storing handles
p = schema.prop(cls, 'Enabled','on/off');
p.FactoryValue = 'on';

% Property for storing handles
p = schema.prop(cls, 'Targets','MATLAB array');
p.Visible = 'on';
p.AccessFlags.PublicSet = 'off';

% Property for storing the property names
p = schema.prop(cls, 'PropertyNames','MATLAB array');
p.Visible = 'on';
p.AccessFlags.PublicSet = 'off';

% Property for storing the property names
p = schema.prop(cls, 'Listeners','MATLAB array');
p.Visible = 'off';

% Property for storing internal listeners
p = schema.prop(cls, 'InternalListeners','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';

% Property for storing internal listeners
p = schema.prop(cls, 'TargetDeletionListeners','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';

% Property for mimicing private method (which is
% current not available in MATLAB)
p = schema.prop(cls, 'UpdateFcn','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';




