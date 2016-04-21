function [z2, p2, k2, allpassnum, allpassden] = zpkrateup(z, p, k, N)
%ZPKRATEUP Zero-pole-gain integer upsample frequency transformation.
%   [Z2,P2,K2,AllpassNum,AllpassDen] = ZPKRATEUP(Z,P,K,N) returns zeros, Z2,
%   poles, P2, and gain factor, K2, of the transformed lowpass digital filter.
%   It also returns the numerator, ALLPASSNUM, and a denominator, ALLPASSDEN,
%   of the allpass mapping filter. The prototype lowpass filter is given with
%   zeros, Z, poles, P, and gain factor, K.
%
%   Inputs:
%     Z          - Zeros of the prototype lowpass filter
%     P          - Poles of the prototype lowpass filter
%     K          - Gain factor of the prototype lowpass filter
%     N          - The frequency multiplication ratio
%   Outputs:
%     Z2         - Zeros of the target filter
%     P2         - Poles of the target filter
%     K2         - Gain factor of the target filter
%     AllpassDen - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Example:
%        [b, a]     = ellip(3,0.1,30,0.409);      % IIR halfband filter
%        z          = roots(b);
%        p          = roots(a);
%        k          = b(1);
%        [z2,p2,k2] = zpkrateup(z, p, k, 4);
%        fvtool(b, a, k2*poly(z2), poly(p2));
%
%   See also ZPKFTRANSF.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:56 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(4,4,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpassrateup(N);

% Perform the transformation
[z2, p2, k2]             = zpkftransf(z, p, k, allpassnum, allpassden);
