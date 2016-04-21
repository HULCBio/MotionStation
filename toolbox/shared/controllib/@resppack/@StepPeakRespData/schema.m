function schema
%  SCHEMA  Defines properties for @StepPeakRespData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:42 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(findpackage('wavepack'), 'TimePeakAmpData');

% Register class (subclass)
c = schema.class(pkg, 'StepPeakRespData', supclass);

% Public attributes
schema.prop(c, 'OverShoot', 'MATLAB array'); % OverShoot Data