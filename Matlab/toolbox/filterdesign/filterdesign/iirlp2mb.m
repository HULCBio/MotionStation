function [num, den, allpassnum, allpassden] = iirlp2mb(b, a, wo, wt, varargin)
%IIRLP2MB IIR lowpass to M-band frequency transformation.
%   [Num,Den,AllpassNum,AllpassDen] = IIRLP2MB(B,A,Wo,Wt,Pass) returns
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
%     Wt         - Desired frequency location in the transformed target filter.
%     Pass       - Choice of the passband or stopband at DC ('pass'/'stop')
%                  The default is 'pass'.
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
%        [b, a]       = ellip(3, 0.1, 30, 0.409); % IIR halfband filter
%        [num1, den1] = iirlp2mb(b, a, 0.5, [2 4 6 8]/10);
%        [num2, den2] = iirlp2mb(b, a, 0.5, [2 4 6 8]/10, 'pass');
%        [num3, den3] = iirlp2mb(b, a, 0.5, [2 4 6 8]/10, 'stop');
%        fvtool(b, a, num1, den1, num2, den2, num3, den3);
%
%   See also IIRFTRANSF, ALLPASSLP2MB and ZPKLP2MB.

%   References:
%     [1] Franchitti, J. C., "All-pass filter interpolation and frequency
%         transformation problems", MSc Thesis, Dept. of Electrical and
%         Computer Engineering, University of Colorado, 1985.
%     [2] Feyh, G., J. C. Franchitti and C. T. Mullis, "All-pass filter
%         interpolation and frequency transformation problem", Proc./20th
%         Asilomar Conf. on Signals, Systems and Computers, Pacific Grove,
%         California, pp. 164-168, 10-12 Nov. 1986.
%     [3] Mullis, C. T. and R. A. Roberts, "Digital Signal Processing",
%         Section 6.7, Reading, Mass., Addison-Wesley, 1987.
%     [4] Feyh, G., W. B. Jones and C. T. Mullis, "An extension of the Schur
%         Algorithm for frequency transformations", Linear Circuits, Systems
%         and Signal Processing: Theory and Application, C. J. Byrnes et al
%         Eds, Amsterdam: Elsevier, 1988.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:42:53 $

% --------------------------------------------------------------------

% Check for number of input arguments
error(nargchk(4,5,nargin));

% Calculate mapping filter
[allpassnum, allpassden] = allpasslp2mb(wo, wt, varargin{:});

% Perform the transformation
[num, den]               = iirftransf(b, a, allpassnum, allpassden);
