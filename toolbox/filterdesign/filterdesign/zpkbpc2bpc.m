function [z2, p2, k2, allpassnum, allpassden] = zpkbpc2bpc(z, p, k, wo, wt)
%ZPKBPC2BPC Zero-pole-gain complex bandpass frequency transformation.
%   [Z2,P2,K2,AllpassNum,AllpassDen] = ZPKBPC2BPC(Z,P,K,Wo,Wt)
%   returns zeros, Z2, poles, P2, and gain factor, K2, of the transformed
%   lowpass digital filter. It also returns the numerator, ALLPASSNUM, and the
%   denominator, ALLPASSDEN, of the allpass mapping filter. The prototype
%   lowpass filter is given with zeros, Z, poles, P, and gain factor, K.
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
%     AllpassDen - denominator of the mapping filter
%
%   Frequencies must be normalized to be between -1 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        % Design prototype IIR halfband filter
%        [b, a]     = ellip(3,0.1,30,0.409);
%        % Create complex passband from 0.25 to 0.75
%        [b, a]     = iirlp2bpc(b,a,0.5,[0.25,0.75]);
%        z          = roots(b);
%        p          = roots(a);
%        k          = b(1);
%        [z2,p2,k2] = zpkbpc2bpc(z, p, k, [0.25, 0.75], [-0.75, -0.25]);
%        fvtool(b, a, k2*poly(z2), poly(p2));
%
%   See also ZPKFTRANSF.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:20 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(5, 5, nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpassbpc2bpc(wo, wt);

% Perform the transformation
[z2, p2, k2]             = zpkftransf(z, p, k, allpassnum, allpassden);
