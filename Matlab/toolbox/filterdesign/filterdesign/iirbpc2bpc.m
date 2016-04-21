function [num, den, allpassnum, allpassden] = iirbpc2bpc(b, a, wo, wt)
%IIRBPC2BPC IIR complex bandpass frequency transformation.
%   [Num,Den,AllpassNum,AllpassDen] = IIRBPC2BPC(B,A,Wo,Wt) returns
%   numerator and denominator vectors, NUM and DEN of the transformed lowpass
%   digital filter. It also returns the numerator, ALLPASSNUM, and the
%   denominator, ALLPASSDEN, of the allpass mapping filter. The prototype
%   lowpass filter is given with the numerator specified by B and the
%   denominator specified by A.
%
%   Inputs:
%     B          - Numerator of the prototype lowpass filter
%     A          - Denominator of the prototype lowpass filter
%     Wo         - Frequency values to be transformed from the prototype filter.
%     Wt         - Desired frequency locations in the transformed target filter.
%   Outputs:
%     Num        - Numerator of the target filter
%     Den        - Denominator of the target filter
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between -1 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        [b, a]     = ellip(3, 0.1, 30, 0.409);            % IIR halfband filter
%        [b, a]     = iirlp2bpc (b, a,  0.5, [0.25,0.75]); % Create complex passband from 0.25 to 0.75
%        [num, den] = iirbpc2bpc(b, a, [0.25,  0.75], [-0.5, 0.5]);
%        fvtool(b, a, num, den);
%
%   See also IIRFTRANSF, ALLPASSBPC2BPC and ZPKBPC2BPC.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:42:44 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(4,4,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpassbpc2bpc(wo, wt);

% Perform the transformation
[num, den]               = iirftransf(b, a, allpassnum, allpassden);
