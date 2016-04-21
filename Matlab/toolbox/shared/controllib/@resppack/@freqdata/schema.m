function schema
%   SCHEMA  Defines properties for @freqdata class

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:42 $

% Find parent class (superclass)
supclass = findclass(findpackage('wrfc'), 'data');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'freqdata', supclass);

% Public attributes
schema.prop(c, 'Focus', 'MATLAB array');         % Focus (preferred frequency range)
schema.prop(c, 'Frequency', 'MATLAB array');     % Frequency vector
p = schema.prop(c, 'FreqUnits', 'string');       % Frequency units
p.FactoryValue = 'rad/sec';
schema.prop(c, 'Response', 'MATLAB array');      % Frequency response data
schema.prop(c, 'SoftFocus', 'bool');             % Soft vs hard focus bounds (default=0)