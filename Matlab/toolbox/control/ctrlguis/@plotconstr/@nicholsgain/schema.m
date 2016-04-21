function schema
%SCHEMA  Defines properties for @nicholsgain margin class

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:11:27 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk, 'nicholsgain', findclass(pk, 'designconstr'));

% Editor data
p = schema.prop(c, 'MagnitudeUnits', 'string'); % Magnitude units
p.FactoryValue = 'dB';
schema.prop(c, 'MarginGain', 'mxArray');     % Gain margin (in dB)
schema.prop(c, 'OriginPha',  'mxArray');     % Phase origin (in deg)
p = schema.prop(c, 'PhaseUnits', 'string');  % Phase units
p.FactoryValue = 'deg';
