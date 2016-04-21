function h = nyquist(varargin)
%NYQUIST   Construct a nyquist design object.
%   Hs = FDESIGN.NYQUIST(L) constructs a Nyquist design object Hs and sets
%   its Band to L.
%
%   The Band of a Nyquist filter is the inverse of the cutoff frequency in
%   terms of normalized units. For instance, a 4th-band filter has a cutoff
%   of 1/4. The case L=2 is refered to as a halfband filter. Use
%   FDESIGN.HALFBAND for more options with halfband filter design.
%
%   Hs = FDESIGN.NYQUIST(L,SPECTYPE) constructs an object and sets its
%   'SpecificationType' to SPECTYPE.  SPECTYPE is one of the following
%   strings and is not case sensitive:
%
%       'TW,Ast' - transition width in normalized frequency units,
%                  stopband attenuation in dB (this is the default)
%       'N,TW'   - filter order, transition width
%       'N'      - filter order
%       'N,Ast'  - filter order, stopband attenuation
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(Hs) to get a list of design methods
%   available for a given SPECTYPE.
%
%   Hs = FDESIGN.NYQUIST(L, SPECTYPE, SPEC1, SPEC2, ...) constructs an
%   object and sets its specifications to SPEC1, SPEC2, etc. at
%   construction time.
%
%   Hs = FDESIGN.NYQUIST(L, TransitionWidth, Astop) uses the  default
%   SPECTYPE ('TW,Ast') and sets the transition width and stopband        
%   attenuation.
%
%   Hs = FDESIGN.NYQUIST(...,Fs) specifies the sampling frequency (in
%   Hz). In this case, the transition width, if specified, is also in Hz.
%
%   Hs = FDESIGN.NYQUIST(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1,  pass the specs to the default 'SpecificationType':
%   hs = fdesign.nyquist(4,.01, 80);
%   designmethods(hs);
%   hd = kaiserwin(hs); % Design filter using Kaiser window.
%
%   % Example #2, pass a new specification type:
%   hs = fdesign.nyquist(5,'n,ast', 42, 80)
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/HALFBAND,
%   FDESIGN/INTERP, FDESIGN/DECIM, FDESIGN/SRC, FDESIGN/LOWPASS.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:29 $

h = fdesign.nyquist(varargin{:});

% [EOF]
