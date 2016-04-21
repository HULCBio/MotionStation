function schema

% Copyright 2003 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'stringbuffer');

% Public properties
schema.prop(cls,'Text','MATLAB array');





