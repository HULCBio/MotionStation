function schema

% Copyright 2003 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'rotate3dbehavior');

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'Rotate3D';

p = schema.prop(cls,'Enable','MATLAB array');
p.FactoryValue = true;
