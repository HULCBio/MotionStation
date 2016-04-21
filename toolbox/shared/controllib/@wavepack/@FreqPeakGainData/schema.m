function schema
%SCHEMA  Defines properties for @FreqPeakGainData class.
%
%  Peak magnitude characteristic (associated with @magphasedata).

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:21 $

% Find parent package
pkg = findpackage('wavepack');

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('wavepack'), 'FreqPeakGainData', superclass);

% Public attributes
schema.prop(c, 'Frequency', 'MATLAB array'); % Frequency where gain peaks
schema.prop(c, 'PeakGain', 'MATLAB array');  % Peak gain
schema.prop(c, 'PeakPhase', 'MATLAB array');  % Phase at peak