function schema
%SCHEMA  Defines properties for @SigmaPeakRespView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:30 $

% Register class (subclass)
wpack = findpackage('wavepack');
c = schema.class(findpackage('resppack'), ...
   'SigmaPeakRespView', findclass(wpack, 'FreqPeakGainView'));