function h = bandstop(varargin)
%BANDSTOP   Construct a bandstop design object.
%   Hs = FDESIGN.BANDSTOP constructs a bandstop filter design object Hs.
%
%   Hs = FDESIGN.BANDSTOP(SPECTYPE) constructs an object and sets its
%   'SpecificationType' to SPECTYPE.  SPECTYPE is one of the following
%   strings and is not case sensitive:
%
%       'Fp1,Fst1,Fst2,Fp2,Ap1,Ast,Ap2' (default)
%       'N,Fc1,Fc2'
%       'N,Fp1,Fp2,Ap'
%       'N,Fst1,Fst2,Ast'
%       'N,Fp1,Fp2,Ap,Ast'
%       'N,Fp1,Fst1,Fst2,Fp2,Ap'
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. Moreover, all magnitude specifications are
%   assumed to be in dB.
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(Hs) to get a list of design methods
%   available for a given SPECTYPE.
%    
%   Hs = FDESIGN.BANDSTOP(SPECTYPE, SPEC1, SPEC2, etc.) constructs an
%   object and sets its specifications to SPEC1, SPEC2, etc. at
%   construction time.
%
%   Hs = FDESIGN.BANDSTOP(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop,
%   Apass2) uses the default SPECTYPE ('Fp1,Fst1,Fst2,Fp2,Ap1,Ast,Ap2')
%   and sets the lower passband-edge frequency, the lower stopband-edge
%   frequency, the upper stopband-edge frequency, the upper passband-edge
%   frequency, the lower passband ripple, the stopband attenuation, and the
%   upper passband ripple.
%
%   Hs = FDESIGN.BANDSTOP(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, all other frequency specifications are also in Hz.
%
%   Hs = FDESIGN.BANDSTOP(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1, pass the specs to the default 'SpecificationType':
%   hs = fdesign.bandstop(.3, .4, .6, .7, .5, 60, 1);
%   designmethods(hs);
%   Hd = ellip(hs,'MatchExactly','passband');
%
%   % Example #2, pass a new specification type:
%   hs = fdesign.bandstop('n,fc1,fc2',12,.4,.6);
%   designmethods(hs);
%   butter(hs);
%
%   % Example #3, set sampling frequency, freq. specs. in Hz:
%   hs = fdesign.bandstop('N,Fp1,Fp2,Ap', 10, 9600, 14400, .5, 48000);
%   designmethods(hs);
%   cheby1(hs);
%
%   % Example #4, pass the magnitude specs. in squared units
%   hs = fdesign.bandstop(.4, .5, .6, .7, .98, .01, .99, 'squared');
%   Hd = cheby2(hs);
%   fvtool(Hd,'MagnitudeDisplay','Magnitude Squared');
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/BANDPASS,
%   FDESIGN/HIGHPASS, FDESIGN/LOWPASS.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:17:14 $

h = fdesign.bandstop(varargin{:});

% [EOF]
