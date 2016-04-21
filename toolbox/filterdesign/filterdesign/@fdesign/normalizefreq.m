function normalizefreq(this)
%NORMALIZEFREQ   Normalize frequency specifications.
%   NORMALIZEFREQ(Hs) will normalize the frequency specifications in Hs.
%   The 'NormalizedFrequency' property will be set to true. In addition,
%   all frequency specifications will be normalized by Fs/2 so that they
%   lie between 0 and 1.
%
%   NORMALIZEFREQ(Hs,BFL) where BFL is either true or false, specifies
%   whether the 'NormalizedFrequency' property will be set to true or
%   false. If not specified, BFL defaults to true. If BFL is set to false,
%   the frequency specifications will be multiplied by Fs/2.
%
%   NORMALIZEFREQ(Hs,false,Fs) allows for the setting of a new sampling
%   frequency, Fs, when the 'NormalizedFrequency' property is set to false.
%
%   See also FDESIGN/LOWPASS, FDESIGN/HIGHPASS, FDESIGN/HALFBAND,
%   FDESIGN/INTERP.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:34:13 $



% [EOF]
