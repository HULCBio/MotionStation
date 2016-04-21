function schema
%SCHEMA  Defines properties for @nicholspeak constraint class

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 05:12:01 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk, 'nicholspeak', findclass(pk, 'designconstr'));

% Editor data
p = schema.prop(c, 'MagnitudeUnits', 'string'); % Magnitude units
p.FactoryValue = 'dB';
schema.prop(c, 'PeakGain',  'mxArray');      % Peak gain (in dB)
schema.prop(c, 'OriginPha', 'mxArray');      % Phase origin (in deg)
p = schema.prop(c, 'PhaseUnits', 'string');  % Phase units
p.FactoryValue = 'deg';
