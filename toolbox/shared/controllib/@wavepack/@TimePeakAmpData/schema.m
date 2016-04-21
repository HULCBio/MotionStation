function schema
%SCHEMA  Defines properties for @TimePeakAmpData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:28 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('wavepack'), 'TimePeakAmpData', superclass);

% Public attributes
schema.prop(c, 'Time', 'MATLAB array');         % Time where amplitude peaks
schema.prop(c, 'PeakResponse', 'MATLAB array'); % Amplitude at peak
