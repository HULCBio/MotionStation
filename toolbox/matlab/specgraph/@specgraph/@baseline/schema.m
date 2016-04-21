function schema()
%SCHEMA Baseline schema

%   Copyright 1984-2003 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('hg');
lineCls = basePkg.findclass('line');

%define class
hClass = schema.class(classPkg , 'baseline', lineCls);
hClass.description = 'A reference base line for a chart';

hProp = schema.prop(hClass, 'BaseValue', 'double');
hProp.Description = 'Base line value';
hProp.FactoryValue = 0.0;
hProp.SetFunction = @LdoBaseValueSet;

hProp = schema.prop(hClass, 'Orientation', 'string');
hProp.Description = 'Base line orientation';
hProp.Visible = 'off';
hProp.FactoryValue = 'X';

hProp = schema.prop(hClass, 'Listener', 'handle');
hProp.Visible = 'off';

function value = LdoBaseValueSet(h, value)
if h.orientation == 'X'
  set(h,'YData',[value value]);
else
  set(h,'XData',[value value]);
end