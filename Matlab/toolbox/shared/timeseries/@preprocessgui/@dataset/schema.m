function schema
%SCHEMA  Defines properties for @preprocess class
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:26 $


% Register class (subclass)
c = schema.class(findpackage('preprocessgui'), 'dataset');

% Time units
if isempty(findtype('TimeUnits'))
    schema.EnumType('TimeUnits', {'years', 'weeks', 'days', 'hours', 'mins', 'secs'});
end

% Public attributes
schema.prop(c, 'Data', 'MATLAB array');
schema.prop(c, 'Datavariable', 'string');
schema.prop(c, 'Name', 'MATLAB array');
schema.prop(c, 'Headings', 'MATLAB array');
p = schema.prop(c, 'Timeunits', 'TimeUnits');
p.FactoryValue = 'secs';
schema.prop(c, 'Time', 'MATLAB array');
schema.prop(c, 'Timevariable', 'string');
schema.prop(c, 'Userdata', 'MATLAB array');
