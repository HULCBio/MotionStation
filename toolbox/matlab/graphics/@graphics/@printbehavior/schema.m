function schema

% Copyright 2003 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'printbehavior');

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'Print';

% Callback that is called with callback(handle,'PrePrintCallback')
p = schema.prop(cls,'PrePrintCallback','MATLAB array');

% Callback that is called with callback(handle,'PostPrintCallback')
p = schema.prop(cls,'PostPrintCallback','MATLAB array');


