function schema
%SCHEMA  Defines properties for @interp class
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:41 $

% Register class (subclass)
c = schema.class(findpackage('preprocessgui'), 'interp');

% Enumerations
if isempty(findtype('interpmethod'))
    schema.EnumType('interpmethod', {'zoh','linear'});
end

% Public attributes
p = schema.prop(c, 'Rowremove', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Rowor', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Interpolate', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'method', 'interpmethod');
p.FactoryValue = 'zoh';

p = schema.prop(c, 'Listeners', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';