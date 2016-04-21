function schema

% Copyright 2004 The MathWorks, Inc.

% get package handle
hCreateInPackage = findpackage('Simulink');

% create class
hThisClass = schema.class(hCreateInPackage, 'BuildInProgress');

% add properties
hThisProp = schema.prop(hThisClass, 'ModelName', 'string');
hThisProp.FactoryValue = '';

hThisProp = schema.prop(hThisClass, 'Listener', 'handle');
hThisProp.FactoryValue = [];
