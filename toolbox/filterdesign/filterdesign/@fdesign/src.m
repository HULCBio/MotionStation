function h = src(varargin)
%SRC   Construct a sample-rate converter (src) design object.
%   Hs = FDESIGN.SRC(L, M) constructs an src filter design object Hs with
%   an 'InterpolationFactor' of L and a 'DecimationFactor' of M.  If L is
%   not specified, it defaults to 3.  If M is not specified it defaults to
%   2.
%
%   Hs = FDESIGN.SRC(L, M, SPECTYPE) constructs an object and sets its
%   'SpecificationType' to SPECTYPE.  SPECTYPE is one of the following
%   strings and is not case sensitive:
%
%       'TW,Ast' - transition width in normalized frequency units,
%                  stopband attenuation in dB (this is the default)
%       'PL,TW'  - polyphase length, transition width      
%       'PL'     - polyphase length
%       'PL,Ast' - polyphase length, stopband attenuation
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(Hs) to get a list of design methods
%   available for a given SPECTYPE.
%
%   Hs = FDESIGN.SRC(L, M, SPECTYPE, SPEC1, SPEC2, ...) constructs an
%   object and sets its specifications to SPEC1, SPEC2, etc. at
%   construction time.
%
%   Hs = FDESIGN.SRC(L, M, TransitionWidth, Astop) uses the  default
%   SPECTYPE ('TW,Ast') and sets the transition width and stopband        
%   attenuation.
%
%   Hs = FDESIGN.SRC(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, the transition width, if specified, is also in Hz.
%
%   Hs = FDESIGN.SRC(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1, pass the specs to the default 'SpecificationType':
%   hs = fdesign.src(5, 3, .05, 40);
%   designmethods(hs)
%   hm = kaiserwin(hs); % Design interpolator using Kaiser window.
%
%   % Example #2, pass a new specification type, only specify order:
%   hs = fdesign.src(2, 3, 'PL,Ast', 12)
%
%   % Example #3, specify a sampling frequency
%   hs = fdesign.src(3, 2,'PL,TW',14,.1,5)
%
%   % Example #4, specify a stopband ripple in linear units
%   hs = fdesign.src(4, 7,'TW,Ast',.1,1e-3,5,'linear') % 1e-3 = 60dB
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/INTERP,
%   FDESIGN/DECIM, FDESIGN/NYQUIST.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:32 $

h = fdesign.src(varargin{:});

% [EOF]
