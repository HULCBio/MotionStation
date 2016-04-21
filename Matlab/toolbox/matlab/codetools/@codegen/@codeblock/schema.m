function schema

% Copyright 2003 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codeblock');

% Hidden properties
p(1) = schema.prop(cls,'Name','MATLAB array');
p(end+1) = schema.prop(cls,'Argin','MATLAB array');
p(end+1) = schema.prop(cls,'Argout','MATLAB array');
p(end+1) = schema.prop(cls,'PostConstructorFunctions','MATLAB array');
p(end+1) = schema.prop(cls,'PreConstructorFunctions','MATLAB array');
p(end+1) = schema.prop(cls,'FunctionObjects','MATLAB array');
p(end+1) = schema.prop(cls,'Constructor','MATLAB array');
p(end+1) = schema.prop(cls,'MomentoRef','MATLAB array');
