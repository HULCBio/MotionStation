function schema
%  SCHEMA  Defines properties for @nyquistplot class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:47 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'respplot');

% Register class (subclass)
c = schema.class(pkg, 'nyquistplot', supclass);

% Properties
p = schema.prop(c, 'FrequencyUnits', 'string');  % Frequency units
p.FactoryValue = 'rad/sec';
p = schema.prop(c, 'ShowFullContour', 'on/off'); % 'on' -> show branch for w<0
p.FactoryValue = 'on';
p = schema.prop(c,'MagnitudeUnits','string');  % Magnitude units for peak response characteristic
p.FactoryValue = 'dB';
p = schema.prop(c,'PhaseUnits','string');  % Phase units for phase margin characteristic
p.FactoryValue = 'deg';