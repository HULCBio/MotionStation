function schema
% Defines properties for @bodegain class

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:07:55 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'bodegain',findclass(pk,'designconstr'));

% Editor data
schema.prop(c,'Frequency','mxArray');   % Start and end frequency (in rad/sec)
p = schema.prop(c,'FrequencyUnits','string');   % Frequency units
p.FactoryValue = 'rad/sec';
schema.prop(c,'Magnitude','mxArray');   % Corresponding gains (in dB)
p = schema.prop(c,'MagnitudeUnits','string');   % Magnitude units
p.FactoryValue = 'dB';
schema.prop(c,'Ts','double');           % Current sampling time (conditions visibility)
