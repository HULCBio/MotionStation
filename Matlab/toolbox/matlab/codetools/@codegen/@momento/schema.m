function schema

% Copyright 2003 The MathWorks, Inc.

% Encapsulate state of class

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'momento');

% Public properties
schema.prop(cls,'Name','MATLAB array');
schema.prop(cls,'ObjectRef','MATLAB array');
schema.prop(cls,'PropertyObjects','MATLAB array');
p= schema.prop(cls,'Ignore','MATLAB array');
set(p,'FactoryValue',false);
