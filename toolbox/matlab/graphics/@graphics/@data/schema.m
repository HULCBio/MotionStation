function schema

% Copyright 2003 The MathWorks, Inc.

% This simple object is used to get a pass by 
% reference effect in m-code. 

pk = findpackage('graphics');
cls = schema.class(pk,'data');

% Property for storing handles
p = schema.prop(cls, 'Data','MATLAB array');
