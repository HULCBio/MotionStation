function schema()
%SCHEMA Color change event schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('handle');
baseCls = basePkg.findclass('EventData');

%define class
hClass = schema.class(classPkg , 'colorevent', baseCls);
hClass.description = 'A color change event';

hProp = schema.prop(hClass, 'newValue', 'color');

