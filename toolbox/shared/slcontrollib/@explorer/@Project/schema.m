function schema
% SCHEMA  Defines class attributes for Project class

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:19 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('explorer');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'projectnode');
hCreateInPackage   = findpackage('explorer');

% Construct class
c = schema.class(hCreateInPackage, 'Project', hDeriveFromClass);

% Public Properties
schema.prop(c, 'Model', 'char');

% Java storage
p = schema.prop(c, 'TitleTextFieldUDD', 'MATLAB array');

% Field storage
schema.prop(c, 'DateModified', 'MATLAB array');
schema.prop(c, 'Subject', 'MATLAB array');
schema.prop(c, 'CreatedBy', 'MATLAB array');
schema.prop(c, 'Model', 'MATLAB array');
schema.prop(c, 'Notes', 'MATLAB array');
schema.prop(c, 'OperatingConditions', 'MATLAB array');

% Listeners
p = schema.prop(c, 'NodePropertyListeners', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
