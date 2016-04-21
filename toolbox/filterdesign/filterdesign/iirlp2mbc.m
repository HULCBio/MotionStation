function [num, den, allpassnum, allpassden] = iirlp2mbc(b, a, wo, wt)
%IIRLP2MBC IIR lowpass to complex M-band frequency transformation.
%   [Num,Den,AllpassNum,AllpassDen] = IIRLP2MBC(B,A,Wo,Wc) returns
%   numerator and denominator vectors, NUM and DEN respectively, of the
%   transformed lowpass digital filter. It also returns the numerator,
%   ALLPASSNUM, and the denominator, ALLPASSDEN, of the allpass mapping filter.
%   The prototype lowpass filter is given with a numerator specified by B and
%   the denominator specified by A.
%
%   Inputs:
%     B          - Numerator of the prototype lowpass filter
%     A          - Denominator of the prototype lowpass filter
%     Wo         - Frequency value to be transformed from the prototype filter.
%                  The frequency should be normalized to be between 0 and 1,
%                  with 1 corresponding to half the sample rate.
%     Wc         - Desired frequency location in the transformed target filter.
%                  The frequency should be normalized to be between -1 and 1,
%                  with 1 corresponding to half the sample rate.
%   Outputs:
%     Num        - Numerator of the target filter
%     Den        - Denominator of the target filter
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Example:
%        [b, a]     = ellip(3, 0.1, 30, 0.409); % IIR halfband filter
%        [num, den] = iirlp2mbc(b, a, 0.5, [2 4 6 8]/10);
%        fvtool(b, a, num, den);
%
%   See also IIRFTRANSF, ALLPASSLP2MBC and ZPKLP2MBC.

%   References:
%     [1] Krukowski A. and I. Kale, "High-order complex frequency transformations",
%         Internal report No. 27/2001, Applied DSP and VLSI Research Group,
%         University of Westminster.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:42:56 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(4,4,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpasslp2mbc(wo, wt);

% Perform the transformation
[num, den]               = iirftransf(b, a, allpassnum, allpassden);
