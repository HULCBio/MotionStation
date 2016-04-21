%SETSPECS   Set design specifications on a filter design object.
%   SETSPECS(Hs, S1, S2, etc.) sets the specifications in the filter design
%   (FDESIGN) object Hs in the same way they are specificied in the
%   constructor of Hs.
%
%   SETSPECS(Hs,...,Fs) specifies the sampling frequency (in Hz). In this
%   case, all other frequency specifications are also in Hz.
%
%   SETSPECS(Hs,...,MAGUNITS) specifies the units for any magnitude
%   specification given. MAGUNITS can be one of the following: 'linear',
%   'dB', or 'squared'. If this argument is omitted, 'dB' is assumed. Note
%   that the magnitude specifications are always converted and stored in dB
%   regardless of how they were specified.
%
%   % Example #1:
%   hs = fdesign.lowpass('N,Fc')
%   setspecs(hs, 20, .4);
%   hs
%
%   % Example #2:
%   hs = fdesign.lowpass('N,Fc')
%   setspecs(hs, 20, 4, 20);
%   hs
%
%   % Example #3:
%   hs = fdesign.lowpass
%   setspecs(hs, .4, .5, .1, .05, 'linear');
%   hs
%
%   See also FDESIGN/DESIGNMETHODS, FDESIGN/LOWPASS.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:31 $

% [EOF]
