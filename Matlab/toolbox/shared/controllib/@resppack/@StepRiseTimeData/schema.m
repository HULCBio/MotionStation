function schema
%  SCHEMA  Defines properties for @StepRiseTimeData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:47 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'StepRiseTimeData', superclass);

% Public attributes
schema.prop(c, 'TLow', 'MATLAB array');      % XData
schema.prop(c, 'THigh', 'MATLAB array');     % XData
schema.prop(c, 'Amplitude', 'MATLAB array'); % YData

% Preferences
p = schema.prop(c, 'RiseTimeLimits', 'MATLAB array');
p.FactoryValue = [0.1 0.9];
