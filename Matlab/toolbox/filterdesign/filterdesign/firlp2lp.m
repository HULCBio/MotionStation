function h = firlp2lp(b)
%FIRLP2LP  FIR Type I lowpass to lowpass transformation.
%   G = FIRLP2LP(B) transforms the type I lowpass FIR filter
%   B with zero-phase response Hr(w) to a type I lowpass FIR
%   filter G with zero-phase response 1 - Hr(pi-w).
%
%   If B is a narrowband filter, G will be a wideband filter 
%   and viceversa. 
%
%   The passband and stopband ripples of G will be equal to the
%   stopband and passband ripples of B respectively.
%
%   EXAMPLE:
%      % Overlay the original narrowband lowpass and the
%      % resulting wideband lowpass
%      b = firgr(36,[0 .2 .25 1],[1 1 0 0],[1 5]);
%      zerophase(b);
%      hold on
%      h = firlp2lp(b); 
%      zerophase(h); hold off
%
%   See also FIRLP2HP, ZEROPHASE, IIRLP2LP, IIRLP2HP, IIRLP2BP, IIRLP2BS.

%   References: 
%     [1] T. Saramaki, Finite impulse response filter design, in 
%          Handbook for Digital Signal Processing. S.K. Mitra and
%          J.F. Kaiser Eds. Wiley-Interscience, N.Y., 1993, Chapter 4.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/12 23:25:29 $

error(nargchk(1,1,nargin));


% First compute (-1)^(N/2)*B(-z), this is done for the narrow-band highpass
btemp = firlp2hp(b);

% Now compute z^(-N/2) - (-1)^(N/2)*B(-z)
h = firlp2hp(btemp,'wide');

% [EOF]
