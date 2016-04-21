function schema

% Copyright 2003 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'mcodegenbehavior');

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'MCodeGeneration';

schema.prop(cls,'MCodeConstructorFcn','MATLAB array');
schema.prop(cls,'MCodeIgnoreHandleFcn','MATLAB array');
p = schema.prop(cls,'Enable','MATLAB array');
p.FactoryValue = true;


