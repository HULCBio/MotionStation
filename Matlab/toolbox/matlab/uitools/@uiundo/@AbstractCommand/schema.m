function schema

% Copyright 2002 The MathWorks, Inc.

% Inherit from handle.Operation
pkHandle = findpackage('handle');
clsParent = findclass(pkHandle,'Operation');

pk = findpackage('uiundo');
cls  = schema.class(pk,'AbstractCommand',clsParent);

% Properties
p(1) = schema.prop(cls,'MCodeComment','MATLAB array');
p(1) = schema.prop(cls,'Name','MATLAB array');