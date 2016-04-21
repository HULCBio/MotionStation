function schema

% Copyright 2002 The MathWorks, Inc.

pk = findpackage('uiundo');
c = schema.class(pk,'CommandManager');

% Properties
p(1) = schema.prop(c,'UndoStack','handle vector');
p(2) = schema.prop(c,'RedoStack','handle vector');
p(3) = schema.prop(c,'MaxUndoStackLength','MATLAB array');
set(p(1:3), 'AccessFlags.PublicSet', 'off', 'AccessFlags.PublicGet','on');

p(4) = schema.prop(c,'Verbose','MATLAB array');


% Events
schema.event(c,'CommandStackChanged');
schema.event(c,'CommandAdded');