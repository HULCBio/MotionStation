function schema
%  SCHEMA  Defines properties for @SettleTimeData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:18 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'SettleTimeData', superclass);

% Public attributes
schema.prop(c, 'Time',    'MATLAB array'); % XData
schema.prop(c, 'YSettle', 'MATLAB array'); % YData
schema.prop(c, 'DCGain',  'MATLAB array'); % YData

% Preferences
p = schema.prop(c, 'SettlingTimeThreshold', 'MATLAB array');
p.FactoryValue = 0.02;
