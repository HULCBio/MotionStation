function schema
%SCHEMA  Defines properties for @nicholsphase margin class

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:09:56 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk, 'nicholsphase', findclass(pk, 'designconstr'));

% Editor data
p = schema.prop(c, 'MagnitudeUnits', 'string'); % Magnitude units
p.FactoryValue = 'dB';
schema.prop(c, 'MarginPha', 'mxArray');      % Phase margin (in deg)
schema.prop(c, 'OriginPha', 'mxArray');      % Phase origin (in deg)
p = schema.prop(c, 'PhaseUnits', 'string');  % Phase units
p.FactoryValue = 'deg';
