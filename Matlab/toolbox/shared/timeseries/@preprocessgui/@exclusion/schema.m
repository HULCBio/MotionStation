function schema
%SCHEMA  Defines properties for @exclusion class
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:31 $

% Register class (subclass)
c = schema.class(findpackage('preprocessgui'), 'exclusion');

% Public attributes
p = schema.prop(c, 'Boundsactive', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Outliersactive', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Flatlineactive', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Expressionactive', 'on/off');
p.FactoryValue = 'off';

p = schema.prop(c, 'Xlow', 'double');
p.FactoryValue = -inf;
p.Description = 'time lower bound';
p = schema.prop(c, 'Xlowstrict', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Xhigh', 'double');
p.FactoryValue = inf;
p.Description = 'time upper bound';
p = schema.prop(c, 'Xhighstrict', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Ylow', 'MATLAB array');
p.FactoryValue = -inf;
p.Description = 'data lower bound';
p = schema.prop(c, 'Ylowstrict', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Yhigh', 'MATLAB array');
p.FactoryValue = inf;
p.Description = 'data upper bound';
p = schema.prop(c, 'Yhighstrict', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Outlierwindow', 'double');
p.FactoryValue = 10;
p.Description = 'outlier window length';
p = schema.prop(c, 'Outlierconf', 'double');
p.FactoryValue = 95;
p.Description = 'outlier detection confidence limit';
p = schema.prop(c, 'Mexpression', 'string');
p.FactoryValue = 'abs(x)>1';
p.Description = 'MATLAB expression';
p = schema.prop(c, 'Flatlinelength', 'double');
p.FactoryValue = 5;
p.Description = 'mimimum flatline length';

p = schema.prop(c, 'Listeners', 'MATLAB array');
% p.AccessFlags.PublicGet = 'off';
% p.AccessFlags.PublicSet = 'off';