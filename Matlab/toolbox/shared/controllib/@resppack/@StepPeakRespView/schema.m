function schema
%SCHEMA  Defines properties for @StepPeakRespView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:45 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(findpackage('wavepack'), 'TimePeakAmpView');

% Register class (subclass)
c = schema.class(pkg, 'StepPeakRespView', supclass);