function h = highpass(varargin)
%HIGHPASS   Construct a highpass design object.
%   Hs = FDESIGN.HIGHPASS constructs a highpass filter design object Hs.
%
%   H = FDESIGN.HIGHPASS(SPECTYPE) constructs an object and sets its
%   'SpecificationType' to SPECTYPE.  SPECTYPE is one of the following
%   strings and is not case sensitive:
%
%       'Fst,Fp,Ast,Ap' - stopband-edge frequency, passband-edge frequency
%                         in normalized frequency units, stopband
%                         attenuation, passband ripple, in dB (this is the
%                         default SPECTYPE).
%       'N,Fc'          - order and cutoff frequency
%       'N,Fp,Ap'       - order, passband-edge frequency, passband ripple
%       'N,Fst,Ast'     - order, stopband-edge frequency, stopband attenuation
%       'N,Fp,Ast,Ap'   - order, passband-edge frequency, stopband
%                         attenuation,passband ripple
%       'N,Fst,Fp,Ap'   - order, stopband-edge frequency, passband-edge
%                         frequency, passband ripple
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(Hs) to get a list of design methods
%   available for a given SPECTYPE.
%
%   Hs = FDESIGN.HIGHPASS(SPECTYPE, SPEC1, SPEC2, ...) constructs an object
%   and sets its specifications to SPEC1, SPEC2, etc. at construction time.
%
%   Hs = FDESIGN.HIGHPASS(Fstop, Fpass, Astop, Apass) uses the  default
%   SPECTYPE ('Fst,Fp,Ast,Ap') and sets the stopband-edge frequency,
%   passband-edge frequency, stopband attenuation, and passband ripple.
%
%   Hs = FDESIGN.HIGHPASS(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, all other frequency specifications are also in Hz.
%
%   Hs = FDESIGN.HIGHPASS(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1, pass the specs to the default 'SpecificationType'
%   hs = fdesign.highpass(.4,.5,80,1);
%   designmethods(hs);
%   Hd = ellip(hs,'MatchExactly','both');
%
%   % Example #2, pass a new specification type show design in FVTool:
%   hs = fdesign.highpass('N,Fc',10,.45);
%   designmethods(hs);
%   butter(hs);
%
%   % Example #3, set sampling frequency, freq. specs. in Hz:
%   hs = fdesign.highpass('N,Fp,Ap', 10, 9600, .5, 48000);
%   designmethods(hs);
%   cheby1(hs);
%
%   % Example #4, pass the magnitude specs. in squared units
%   hs = fdesign.highpass(.4, .5, .02, .98, 'squared');
%   Hd = cheby1(hs);
%   fvtool(Hd,'MagnitudeDisplay','Magnitude Squared');
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/LOWPASS,
%   FDESIGN/BANDSTOP, FDESIGN/BANDPASS.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:17:25 $

h = fdesign.highpass(varargin{:});

% [EOF]
