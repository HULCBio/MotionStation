function schema

% Copyright 2002 The MathWorks, Inc.

pk = findpackage('uiundo');
c  = schema.class(pk,'RecordCommand',pk.findclass('AbstractCommand'));

% Properties
p(1) = schema.prop(c,'Target','MATLAB array');
p(2) = schema.prop(c,'TargetProperties','MATLAB array');
set(p(2),'FactoryValue','-auto');
p(3) = schema.prop(c,'Container','MATLAB array');
p(4) = schema.prop(c,'Transaction','MATLAB array');
p(5) = schema.prop(c,'TransactionPropertyListeners','MATLAB array');

