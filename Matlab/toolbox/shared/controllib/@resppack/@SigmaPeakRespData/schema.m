function schema
%SCHEMA  Defines properties for @SigmaPeakRespData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:26 $

% Find parent class (superclass)
supclass = findclass(findpackage('wavepack'), 'FreqPeakGainData');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'SigmaPeakRespData', supclass);
