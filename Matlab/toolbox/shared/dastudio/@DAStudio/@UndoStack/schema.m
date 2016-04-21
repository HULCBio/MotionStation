function schema

% Copyright 2004 The MathWorks, Inc.
  
  pkg = findpackage('DAStudio');
  c = schema.class ( pkg, 'UndoStack');

  
% Define public properties
  schema.prop(c, 'UndoStack', 'handle vector');
  schema.prop(c, 'RedoStack', 'handle vector');
  schema.prop(c, 'CurrentTransactions', 'handle vector');
  schema.prop(c, 'ExternalMarkers', 'double');

% In future, this will be the guy that fires when an operation happens
  % schema.prop(c, 'Listener', 'handle');
  

