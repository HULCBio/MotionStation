function schema
%SCHEMA Plot manager schema

%   Copyright 1984-2003 The MathWorks, Inc. 

pk = findpackage('graphics');
cls = schema.class(pk,'plotmanager');

p = schema.event(cls,'PlotFunctionDone');
