function [z2, p2, k2, allpassnum, allpassden] = zpklp2xn(z, p, k, wo, wt, varargin)
%ZPKLP2XN Zero-pole-gain lowpass to N-point frequency transformation.
%   [Z2,P2,K2,AllpassNum,AllpassDen] = ZPKLP2XN(Z,P,K,Wo,Wt, Pass) returns
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
%     Pass       - Choice ('pass'/'stop') of passband/stopband at DC.
%                  The default value is 'pass'.
%   Outputs:
%     Z2         - Zeros of the target filter
%     P2         - Poles of the target filter
%     K2         - Gain factor of the target filter
%     AllpassDen - Numerator of the mapping filter
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
%        [z1,p1,k1] = zpklp2xn(z, p, k, [-0.5 0.5], [0.25 0.75]);
%        [z2,p2,k2] = zpklp2xn(z, p, k, [-0.5 0.5], [0.25 0.75], 'pass');
%        [z3,p3,k3] = zpklp2xn(z, p, k, [-0.5 0.5], [0.25 0.75], 'stop');
%        fvtool(b,a,k1*poly(z1),poly(p1),k2*poly(z2),poly(p2),k3*poly(z3),poly(p3));
%
%   See also ZPKFTRANSF.

%   References:
%     [1]  Gerry D. Cain, Artur Krukowski, Izzet Kale, "High Order
%          Transformations for Flexible IIR Filter Design", VII European
%          Signal Processing Conference (EUSIPCO'94), Vol. 3, pp. 1582-1585,
%          Edinburgh, United Kingdom, 13-16 September 1994.
%     [2]  Artur Krukowski, Gerald D. Cain, Izzet Kale, "Custom designed
%          high-order frequency transformations for IIR filters", 38th Midwest
%          Symposium on Circuits and Systems (MWSCAS'95), Rio de Janeiro,
%          Brazil, 13-16 August 1995.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:53 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(5,6,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpasslp2xn(wo, wt, varargin{:});

% Perform the transformation
[z2, p2, k2]             = zpkftransf(z, p, k, allpassnum, allpassden);
