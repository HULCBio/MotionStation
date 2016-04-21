function h = lowpass(varargin)
%LOWPASS   Construct a lowpass design object.
%   Hs = FDESIGN.LOWPASS constructs a lowpass filter design object Hs.
%
%   Hs = FDESIGN.LOWPASS(SPECTYPE) constructs an object and sets its
%   'SpecificationType' to SPECTYPE.  SPECTYPE is one of the following
%   strings and is not case sensitive:
%
%       'Fp,Fst,Ap,Ast' - passband-edge frequency, stopband-edge frequency
%                         in normalized frequency units, passband ripple,
%                         stopband attenuation in dB (this is the default
%                         SPECTYPE)
%       'N,Fc'          - order and cutoff frequency
%       'N,Fp,Ap'       - order, passband-edge frequency, passband ripple
%       'N,Fst,Ast'     - order, stopband-edge frequency, stopband attenuation
%       'N,Fp,Ap,Ast'   - order, passband-edge frequency, passband ripple,
%                         stopband attenuation
%       'N,Fp,Fst,Ap'   - order, passband-edge frequency, stopband-edge
%                         frequency, passband ripple
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(Hs) to get a list of design methods
%   available for a given SPECTYPE.
%
%   Hs = FDESIGN.LOWPASS(SPECTYPE, SPEC1, SPEC2, ...) constructs an object
%   and sets its specifications to SPEC1, SPEC2, etc. at construction time.
%
%   Hs = FDESIGN.LOWPASS(Fpass, Fstop, Apass, Astop) uses the  default
%   SPECTYPE ('Fp,Fst,Ap,Ast') and sets the passband-edge frequency,
%   stopband-edge frequency, passband ripple, and stopband attenuation.
%
%   Hs = FDESIGN.LOWPASS(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, all other frequency specifications are also in Hz.
%
%   Hs = FDESIGN.LOWPASS(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1, pass the specs to the default 'SpecificationType'
%   hs = fdesign.lowpass(.4,.5,1,80);
%   designmethods(hs);
%   Hd = ellip(hs,'MatchExactly','both');
%
%   % Example #2, pass a new specification type show design in FVTool:
%   hs = fdesign.lowpass('N,Fc',10,.45);
%   designmethods(hs);
%   butter(hs);
%
%   % Example #3, set sampling frequency, freq. specs. in Hz:
%   hs = fdesign.lowpass('N,Fp,Ap', 10, 9600, .5, 48000);
%   designmethods(hs);
%   cheby1(hs);
%
%   % Example #4, pass the magnitude specs. in squared units
%   hs = fdesign.lowpass(.4, .5, .98, .02, 'squared');
%   Hd = cheby1(hs);
%   fvtool(Hd,'MagnitudeDisplay','Magnitude Squared');
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/HALFBAND,
%   FDESIGN/NYQUIST, FDESIGN/HIGHPASS, FDESIGN/BANDSTOP, FDESIGN/BANDPASS.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:17:28 $

h = fdesign.lowpass(varargin{:});

% [EOF]
