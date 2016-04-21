function h = bandpass(varargin)
%BANDPASS   Construct a bandpass design object.
%   Hs = FDESIGN.BANDPASS constructs a bandpass filter design object Hs.
%
%   Hs = FDESIGN.BANDPASS(SPECTYPE) constructs an object and sets its
%   'SpecificationType' to SPECTYPE.  SPECTYPE is one of the following
%   strings and is not case sensitive:
%
%       'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2' (default)
%       'N,Fc1,Fc2'
%       'N,Fp1,Fp2,Ap'
%       'N,Fst1,Fst2,Ast'
%       'N,Fp1,Fp2,Ast1,Ap,Ast2'
%       'N,Fst1,Fp1,Fp2,Fst2,Ap'
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. Moreover, all magnitude specifications are
%   assumed to be in dB.
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(Hs) to get a list of design methods
%   available for a given SPECTYPE.
%
%   Hs = FDESIGN.BANDPASS(SPECTYPE, SPEC1, SPEC2, ...) constructs an object
%   and sets its specifications to SPEC1, SPEC2, etc. at construction time.
%
%   Hs = FDESIGN.BANDPASS(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass,
%   Astop2) uses the default SPECTYPE ('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2')
%   and sets the lower stopband-edge frequency, the lower passband-edge
%   frequency, the upper passband-edge frequency, the upper stopband-edge
%   frequency, the lower stopband attenuation, the passband ripple, and the
%   upper passband attenuation.
%
%   Hs = FDESIGN.BANDPASS(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, all other frequency specifications are also in Hz.
%
%   Hs = FDESIGN.BANDPASS(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1, pass the specs to the default 'SpecificationType':
%   hs = fdesign.bandpass(.3, .4, .6, .7, 80, .5, 60);
%   designmethods(hs);
%   Hd = ellip(hs,'MatchExactly','passband');
%
%   % Example #2, pass a new specification type:
%   hs = fdesign.bandpass('n,fc1,fc2',12,.4,.6);
%   designmethods(hs);
%   butter(hs);
%
%   % Example #3, set sampling frequency, freq. specs. in Hz:
%   hs = fdesign.bandpass('N,Fp1,Fp2,Ap', 10, 9600, 14400, .5, 48000);
%   designmethods(hs);
%   cheby1(hs);
%
%   % Example #4, pass the magnitude specs. in squared units
%   hs = fdesign.bandpass(.4, .5, .6, .7, .02, .98, .01, 'squared');
%   Hd = cheby2(hs);
%   fvtool(Hd,'MagnitudeDisplay','Magnitude Squared');
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/BANDSTOP,
%   FDESIGN/HIGHPASS, FDESIGN/LOWPASS.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:17:13 $

h = fdesign.bandpass(varargin{:});

% [EOF]
