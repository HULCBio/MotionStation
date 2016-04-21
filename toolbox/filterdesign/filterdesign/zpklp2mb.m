function [z2, p2, k2, allpassnum, allpassden] = zpklp2mb(z, p, k, wo, wt, varargin)
%ZPKLP2MB Zero-pole-gain lowpass to M-band frequency transformation.
%   [Z2,P2,K2,AllpassNum,AllpassDen] = ZPKLP2MB(Z,P,K,Wo,Wt,Pass) returns
%   zeros, Z2, poles, P2, and gain factor, K2, of the transformed lowpass
%   digital filter. It also returns the numerator, ALLPASSNUM, and the
%   denominator, ALLPASSDEN, of the allpass mapping filter. The prototype
%   lowpass filter is given with zeros, Z, poles, P, and gain factor, K.
%
%   Inputs:
%     Z          - Zeros of the prototype lowpass filter
%     P          - Poles of the prototype lowpass filter
%     K          - Gain factor of the prototype lowpass filter
%     Wo         - Frequency value to be transformed from the prototype filter.
%     Wt         - Desired frequency location in the transformed target filter.
%     Pass       - Choice of the passband or stopband at DC ('pass'/'stop')
%                  The default is 'pass'.
%   Outputs:
%     Z2         - Zeros of the target filter
%     P2         - Poles of the target filter
%     K2         - Gain factor of the target filter
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between 0 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        [b, a]     = ellip(3,0.1,30,0.409);      % IIR halfband filter
%        z          = roots(b);
%        p          = roots(a);
%        k          = b(1);
%        [z1,p1,k1] = zpklp2mb(z, p, k, 0.5, [2 4 6 8]/10, 'pass');
%        [z2,p2,k2] = zpklp2mb(z, p, k, 0.5, [2 4 6 8]/10, 'stop');
%        fvtool(b, a, k1*poly(z1), poly(p1), k2*poly(z2), poly(p2));
%
%   See also ZPKFTRANSF.

%   References:
%     [1] Franchitti, J. C., "All-pass filter interpolation and frequency
%         transformation problems", MSc Thesis, Dept. of Electrical and
%         Computer Engineering, University of Colorado, 1985.
%     [2] Feyh, G., J. C. Franchitti and C. T. Mullis, "All-pass filter
%         interpolation and frequency transformation problem", Proc. 20th
%         Asilomar Conf. on Signals, Systems and Computers, Pacific Grove,
%         California, pp. 164-168, 10-12 Nov. 1986.
%     [3] Mullis, C. T. and R. A. Roberts, "Digital Signal Processing",
%         Section 6.7, Reading, Mass., Addison-Wesley, 1987.
%     [4] Feyh, G., W. B. Jones and C. T. Mullis, "An extension of the Schur
%         Algorithm for frequency transformations", Linear Circuits, Systems
%         and Signal Processing: Theory and Application, C. J. Byrnes et al
%         Eds, Amsterdam: Elsevier, 1988.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:44 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(5, 6, nargin));

% Calculate mapping filter
[allpassnum, allpassden] = allpasslp2mb(wo, wt, varargin{:});

% Perform the transformation
[z2, p2, k2]             = zpkftransf(z, p, k, allpassnum, allpassden);
