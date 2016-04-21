function schema
% Tuned parameter class.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:46 $
sp = findclass(findpackage('slcontrol'),'Parameter');
c = schema.class(findpackage('ResponseOptimizer'),'Parameter',sp);

% Tuned flag
p = schema.prop(c, 'Tuned', 'MATLAB array');
p.SetFunction = @LocalSetValue;

%---------- local functions

function value = LocalSetValue(this, value)
try
   value = logical(value);
catch
   error('Cannot convert assigned value to logical.')
end
value = utCheckSize(this,value,1);
