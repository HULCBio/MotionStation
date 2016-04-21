function schema

% Copyright 2003-2004 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codefunction');

% Hidden properties
p(1) = schema.prop(cls,'Name','MATLAB array');
p(end+1) = schema.prop(cls,'Argout','MATLAB array');
p(end+1) = schema.prop(cls,'Argin','MATLAB array');
p(end+1) = schema.prop(cls,'CodeRef','MATLAB array');
p(end+1) = schema.prop(cls,'Comment','MATLAB array');


