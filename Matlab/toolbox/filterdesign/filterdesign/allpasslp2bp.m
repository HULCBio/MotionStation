function [allpassnum, allpassden] = allpasslp2bp(wo, wt)
%ALLPASSLP2BP Allpass for lowpass to bandpass frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSLP2BP(Wo,Wt) returns numerator,
%   ALLPASSNUM, and the denominator, ALLPASSDEN, of the allpass mapping filter.
%
%   Inputs:
%     Wo         - Frequency value to be transformed from the prototype filter.
%     Wt         - Desired frequency location in the transformed target filter.
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between 0 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        % Allpass mapper changing the lowpass with cutoff frequency of Wo=0.5
%        % to the real bandpass with cutoff frequencies at Wt1=0.25 and Wt2=0.375
%        Wo = 0.5;
%        Wt = [0.25, 0.375];
%        [AllpassNum, AllpassDen] = allpasslp2bp(Wo, Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, abs(angle(h))/pi, Wt, Wo, 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2BP and ZPKLP2BP.

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
%   $Revision: 1.3 $  $Date: 2002/04/14 15:44:08 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,2,nargin));

error(ftransfargchk(wo, 'Frequency value from the prototype filter', ...
                        'scalar',  'real', 'normalized'));
error(ftransfargchk(wt, 'Desired frequency location in the target filter', ...
                        'vector2', 'real', 'normalized'));

% ---------------------------------------------------------------------
% Calculate the mapping filter

bw         = abs(wt(2) - wt(1));
alpha      = sin(pi*(wo-bw)/2) / sin(pi*(wo+bw)/2);
beta       = cos(pi*sum(wt)/2) / cos(pi*bw/2);
allpassden =  [alpha -beta*(1+alpha) 1];
allpassnum = -fliplr(allpassden);
