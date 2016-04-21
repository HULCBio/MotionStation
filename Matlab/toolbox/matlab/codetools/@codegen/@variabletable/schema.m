function schema

% Copyright 2003 The MathWorks, Inc.

% Used by MAKEMCODE to insure unique variable names.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'variabletable');

% Public properties
schema.prop(cls,'VariableList','MATLAB array');
schema.prop(cls,'ParameterList','MATLAB array');
p= schema.prop(cls,'VariableNameList','MATLAB array');
set(p,'FactoryValue',cell(0));
schema.prop(cls,'VariableNameListCount','MATLAB array');





