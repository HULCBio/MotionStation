function h = halfband(varargin)
%HALFBAND   Construct a halfband design object.
%   Hs = FDESIGN.HALFBAND constructs a halfband filter design object Hs.
%
%   Hs = FDESIGN.HALFBAND(SPECTYPE) constructs an object and sets its
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
%   Hs = FDESIGN.HALFBAND(SPECTYPE, SPEC1, SPEC2, ...)  constructs an
%   object and sets its specifications to SPEC1, SPEC2, etc. at
%   construction time.
%
%   Hs = FDESIGN.HALFBAND(TransitionWidth, Astop) uses the  default
%   SPECTYPE ('TW,Ast') and sets the transition width and stopband        
%   attenuation.
%
%   Hs = FDESIGN.HALFBAND(...,Fs) specifies the sampling frequency (in
%   Hz). In this case, the transition width, if specified, is also in Hz.
%
%   Hs = FDESIGN.HALFBAND(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1, pass the specs to the default 'SpecificationType'
%   hs = fdesign.halfband(.01, 80);
%   designmethods(hs);
%   Hd = equiripple(hs);
%
%   % Example #2, pass a new specification type, design an equiripple FIR:
%   hs = fdesign.halfband('n,ast',80,70);
%   equiripple(h); % FVTool will be launched
%
%   % Example #3, pass the specs, design a least-squares FIR
%   hs = fdesign.halfband('n,tw', 42, .04);
%   designmethods(hs);
%   Hd = firls(hs);
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/NYQUIST,
%   FDESIGN/INTERP, FDESIGN/DECIM, FDESIGN/SRC, FDESIGN/LOWPASS.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:17:24 $

h = fdesign.halfband(varargin{:});

% [EOF]
