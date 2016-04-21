function schema

% Copyright 2003 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'momentoproperty');

% Public properties
schema.prop(cls,'Name','MATLAB array');
schema.prop(cls,'Value','MATLAB array');
schema.prop(cls,'Object','MATLAB array');
p = schema.prop(cls,'Ignore','MATLAB array');
set(p,'FactoryValue',false);
p = schema.prop(cls,'IsParameter','MATLAB array');
set(p,'FactoryValue',false);





