function [z2, p2, k2, allpassnum, allpassden] = zpkshiftc(z, p, k, wo, wt)
%ZPKSHIFTC Zero-pole-gain complex shift frequency transformation.
%   [Z2,P2,K2,AllpassNum,AllpassDen] = ZPKSHIFTC(Z,P,K,Wo,Wt) returns zeros,
%   Z2, poles, P2, and gain factor, K2, of the transformed lowpass digital
%   filter as well as the numerator, ALLPASSNUM, and the denominator,
%   ALLPASSDEN, of the allpass mapping filter. The prototype lowpass filter
%   is given with zeros, Z, poles, P, and gain factor, K.
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
%     AllpassDen - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   [Z2,P2,K2,Nmap,Dmap] = ZPKSHIFTC(Z,P,K,0,0.5) performs the Hilbert
%   transformation, e.i. a 90 degrees clockwise rotation of the original
%   filter in the frequency domain.
%
%   [Z2,P2,K2,Nmap,Dmap] = ZPKSHIFTC(Z,P,K,0,-0.5) performs the Hilbert
%   transformation, e.i. a 90 degrees anticlockwise rotation of the original
%   filter in the frequency domain.
%
%   Frequencies must be normalized to be between -1 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        [b, a]     = ellip(3,0.1,30,0.409);        % IIR halfband filter
%        z          = roots(b);
%        p          = roots(a);
%        k          = b(1);
%
%        [z2,p2,k2] = zpkshiftc(z, p, k, 0.5, 0.25); % Rotation by 0.25
%        fvtool(b, a, k2*poly(z2), poly(p2));
%
%        [z2,p2,k2] = zpkshiftc(z, p, k, 0.5, 0.5);  % Hilbert transform
%        fvtool(b, a, k2*poly(z2), poly(p2));
%
%        [z2,p2,k2] = zpkshiftc(z, p, k, 0.5, -0.5); % Inverse Hilbert transform
%        fvtool(b, a, k2*poly(z2), poly(p2));
%
%   See also ZPKFTRANSF.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:44:02 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(5,5,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpassshiftc(wo, wt);

% Perform the transformation
[z2, p2, k2]             = zpkftransf(z, p, k, allpassnum, allpassden);
