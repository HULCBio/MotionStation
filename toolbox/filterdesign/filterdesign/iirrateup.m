function [num, den, allpassnum, allpassden] = iirrateup(b, a, N)
%IIRRATEUP IIR integer upsample frequency transformation.
%   [Num,Den,AllpassNum,AllpassDen] = IIRRATEUP(B,A,N) returns numerator and
%   denominator vectors, NUM and DEN of the transformed lowpass digital filter.
%   It also returns the numerator, ALLPASSNUM, and the denominator, ALLPASSDEN,
%   of the allpass mapping filter.  The prototype lowpass filter is given with
%   a numerator specified by B and a denominator specified by A.
%
%   Inputs:
%     B          - Numerator of the prototype lowpass filter
%     A          - Denominator of the prototype lowpass filter
%     N          - The frequency multiplication ratio
%   Outputs:
%     Num        - Numerator of the target filter
%     Den        - Denominator of the target filter
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Example:
%        [b, a]     = ellip(3, 0.1, 30, 0.409); % IIR halfband filter
%        [num, den] = iirrateup(b, a, 4);
%        fvtool(b, a, num, den);
%
%   See also IIRFTRANSF, ALLPASSRATEUP and ZPKRATEUP.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:05 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(3,3,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpassrateup(N);

% Perform the transformation
[num, den]               = iirftransf(b, a, allpassnum, allpassden);
