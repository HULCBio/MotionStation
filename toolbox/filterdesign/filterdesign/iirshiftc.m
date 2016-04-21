function [num, den, allpassnum, allpassden] = iirshiftc(b, a, wo, wt)
%IIRSHIFTC IIR complex shift frequency transformation.
%   [Num,Den,AllpassNum,AllpassDen] = IIRSHIFTC(B,A,Wo,Wc) returns numerator
%   and denominator vectors, NUM and DEN of the transformed lowpass digital
%   filter. It also returns the numerator, ALLPASSNUM, and the denominator,
%   AllpassDen, of the allpass mapping filter.  The prototype lowpass filter
%   is given with the numerator specified by B and the denominator specified
%   by A.
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
%   [NUM,DEN,Nmap,Dmap] = IIRPASSSHIFTC(B,A,0,0.5) performs the Hilbert
%   frequency transformation on the original filter, e.i. rotates it by 90
%   degrees clockwise in the frequency domain.
%
%   [NUM,DEN,Nmap,Dmap] = IIRPASSSHIFTC(B,A,0,0.5) performs the inverse Hilbert
%   frequency transformation on the original filter, e.i. rotates it by 90
%   degrees anticlockwise in the frequency domain.
%
%   Frequencies must be normalized to be between -1 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        [b, a]     = ellip(3, 0.1, 30, 0.409); % IIR halfband filter
%        [num, den] = iirshiftc(b, a, 0.5, 0.25);
%        fvtool(b, a, num, den);
%
%   See also IIRFTRANSF, ALLPASSSHIFTC and ZPKSHIFTC.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:43:11 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(4,4,nargin));

% Calculate the mapping filter
[allpassnum, allpassden] = allpassshiftc(wo, wt);

% Perform the transformation
[num, den]               = iirftransf(b, a, allpassnum, allpassden);
