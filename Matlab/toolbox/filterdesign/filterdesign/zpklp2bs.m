function [z2, p2, k2, allpassnum, allpassden] = zpklp2bs(z, p, k, wo, wt)
%ZPKLP2BS Zero-pole-gain lowpass to bandstop frequency transformation.
%   [Z2,P2,K2,AllpassNum,AllpassDen] = ZPKLP2BS(Z,P,K,Wo,Wt) returns zeros,
%   Z2, poles, P2, and gain factor, K2, of the transformed lowpass digital
%   filter as well as the numerator, ALLPASSNUM, and the denominator,
%   ALLPASSDEN, of the allpass mapping filter. The prototype lowpass filter is
%   given with zeros, Z, poles, P, and gain factor, K.
%
%   Inputs:
%     Z          - Zeros of the prototype lowpass filter
%     P          - Poles of the prototype lowpass filter
%     K          - Gain factor of the prototype lowpass filter
%     Wo         - Frequency value to be transformed from the prototype filter.
%     Wt         - Desired frequency location in the transformed target filter.
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
%        [z2,p2,k2] = zpklp2bs(z, p, k, 0.5, [0.2 0.3]);
%        fvtool(b, a, k2*poly(z2), poly(p2));
%
%   See also ZPKFTRANSF.

%   References:
%     [1] Constantinides A.G., "Spectral transformations for digital filters",
%         IEE Proceedings, vol. 117, no. 8, pp. 1585-1590, August 1970.
%     [2] Nowrouzian, B. and A. G. Constantinides, "Prototype reference
%         transfer function parameters in the discrete-time frequency
%         transformations", Proc. 33rd Midwest Symposium on Circuits and
%         Systems, Calgary, Canada, vol. 2, pp. 1078-1082, 12-14 August 1990.
%     [3] Nowrouzian, B. and Bruton, L.T. "Closed-form solutions for
%         discrete-time elliptic transfer functions", Proceedings of
%         the 35th Midwest Symposium on Circuits and Systems, vol. 2,
%         Page(s): 784 -787, 1992.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:32 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(5, 5, nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpasslp2bs(wo, wt);

% Perform the transformation
[z2, p2, k2]             = zpkftransf(z, p, k, allpassnum, allpassden);
