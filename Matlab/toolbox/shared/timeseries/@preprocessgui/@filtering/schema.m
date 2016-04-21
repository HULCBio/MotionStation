function schema
%SCHEMA  Defines properties for @exclusion class
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:36 $


% Register class (subclass)
c = schema.class(findpackage('preprocessgui'), 'filtering');

% Enumerations
if isempty(findtype('detrend'))
    schema.EnumType('detrend', {'constant','line'});
end
if isempty(findtype('filtertype'))
    schema.EnumType('filtertype', {'ideal','transfer','firstord'});
end
if isempty(findtype('filterband'))
    schema.EnumType('filterband', {'pass','stop'});
end

% Public attributes
p = schema.prop(c, 'Detrendactive', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Filteractive', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Detrendtype', 'detrend');
p.FactoryValue = 'constant';
p = schema.prop(c, 'Filter', 'filtertype');
p.FactoryValue = 'firstord';
p = schema.prop(c, 'Band', 'filterband');
p.FactoryValue = 'pass';
p = schema.prop(c, 'Range', 'MATLAB array');
p.Description = 'frequency range';
p.FactoryValue = [0 0.1];
p = schema.prop(c, 'Acoeffs', 'MATLAB array');
p.FactoryValue = [1 10];
p.Description = 'numerator coefficients';
p = schema.prop(c, 'Bcoeffs', 'MATLAB array');
p.FactoryValue = 1;
p.Description = 'denominator coefficients';
p = schema.prop(c, 'Timeconst', 'double');
p.Description = 'time constant';
p.FactoryValue = 10;

p = schema.prop(c, 'Listeners', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';