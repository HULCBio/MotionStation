function h = interp(varargin)
%INTERP   Construct an interp design object.
%   Hs = FDESIGN.INTERP(L) constructs an interp filter design object Hs
%   with an 'InterpolationFactor' of L. If L is not specified, it defaults
%   to 2.
%
%   Hs = FDESIGN.INTERP(L, SPECTYPE) constructs an object and sets its
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
%   Hs = FDESIGN.INTERP(L, SPECTYPE, SPEC1, SPEC2, ...) constructs an
%   object and sets its specifications to SPEC1, SPEC2, etc. at
%   construction time.
%
%   Hs = FDESIGN.INTERP(L, TransitionWidth, Astop) uses the  default
%   SPECTYPE ('TW,Ast') and sets the transition width and stopband        
%   attenuation.
%
%   Hs = FDESIGN.INTERP(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, the transition width, if specified, is also in Hz.
%
%   Hs = FDESIGN.INTERP(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1, pass the specs to the default 'SpecificationType':
%   hs = fdesign.interp(5, .05, 40);
%   designmethods(hs);
%   hm = kaiserwin(hs); % Design interpolator using Kaiser window.
%
%   % Example #2, pass a new specification type, only specify order:
%   hs = fdesign.interp(4, 'PL,Ast', 12)
%
%   % Example #3, specify a sampling frequency
%   hs = fdesign.interp(2,'PL,TW',18,.1,5)
%   designmethods(hs); 
%   equiripple(hs); % Launches FVTool
%
%   % Example #4, specify a stopband ripple in linear units
%   hs = fdesign.interp(4,'TW,Ast',.1,1e-3,5,'linear') % 1e-3 = 60dB
%
%   See also FDESIGN/SETSPECS, FDESIGN/DESIGNMETHODS, FDESIGN/DECIM,
%   FDESIGN/HALFBAND, FDESIGN/NYQUIST, FDESIGN/SRC.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:26 $

h = fdesign.interp(varargin{:});

% [EOF]
