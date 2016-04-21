function [num, den, allpassnum, allpassden] = iirlp2xn(b,a,wo,wt,varargin)
%IIRLP2XN IIR lowpass to N-point frequency transformation.
%   [Num,Den,AllpassNum,AllpassDen] = IIRLP2XN(B,A,Wo,Wt,Pass) returns
%   numerator and denominator vectors, NUM and DEN of the transformed lowpass
%   digital filter. It also returns the numerator, ALLPASSNUM, and the
%   denominator, ALLPASSDEN, of the allpass mapping filter. The prototype
%   lowpass filter is given with the numerator specified by B and the
%   denominator specified by A.
%
%   Inputs:
%     B          - Numerator of the prototype lowpass filter
%     A          - Denominator of the prototype lowpass filter
%     Wo         - Frequency values to be transformed from the prototype filter
%     Wt         - Desired frequency locations in the transformed target filter
%     Pass       - ('pass'/'stop') for passband/stopband at DC.
%   Outputs:
%     Num        - Numerator of the target filter
%     Den        - Denominator of the target filter
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between 0 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        [b, a]     = ellip(3, 0.1, 30, 0.409); % IIR halfband filter
%        [num, den] = iirlp2xn(b, a, [-0.5 0.5], [0.25 0.75], 'pass');
%        fvtool(b, a, num, den);
%
%   See also IIRFTRANSF, ALLPASSLP2XN and ZPKLP2XN.

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
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:02 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(4,5,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpasslp2xn(wo, wt, varargin{:});

% Perform the transformation
[num, den]               = iirftransf(b, a, allpassnum, allpassden);
