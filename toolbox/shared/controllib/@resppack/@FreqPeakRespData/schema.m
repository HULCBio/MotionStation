function schema
%SCHEMA  Defines properties for @FreqPeakRespData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:47 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'FreqPeakRespData', superclass);

% Public attributes
schema.prop(c, 'Frequency', 'MATLAB array');     % Frequency where gain peak
schema.prop(c, 'PeakResponse', 'MATLAB array');  % Complex response at peak
