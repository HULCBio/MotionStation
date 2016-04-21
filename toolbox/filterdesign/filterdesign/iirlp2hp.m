function [num, den, allpassnum, allpassden] = iirlp2hp(b, a, wo, wt)
%IIRLP2HP IIR lowpass to complex highpass frequency transformation.
%   [Num,Den,AllpassNum,AllpassDen] = IIRLP2HP(B,A,Wo,Wt) returns numerator and
%   denominator vectors, NUM and DEN of the transformed lowpass digital filter.
%   It also returns the numerator, ALLPASSNUM, and the denominator, ALLPASSDEN,
%   of the allpass mapping filter.  The prototype lowpass filter is given with
%   the numerator specified by B and the denominator specified by A.
%
%   Inputs:
%     B          - Numerator of the prototype lowpass filter
%     A          - Denominator of the prototype lowpass filter
%     Wo         - Frequency value to be transformed from the prototype filter.
%     Wt         - Desired frequency location in the transformed target filter.
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
%        [num, den] = iirlp2hp(b, a, 0.5, 0.25);
%        fvtool(b, a, num, den);
%
%   See also IIRFTRANSF, ALLPASSLP2HP and ZPKLP2HP.

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
%   $Revision: 1.6 $  $Date: 2002/04/14 15:42:38 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(4,4,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpasslp2hp(wo, wt);

% Perform the transformation
[num,den]  = iirftransf(b, a, allpassnum, allpassden);
