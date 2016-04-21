function [allpassnum, allpassden] = allpasslp2hp(wo, wt)
%ALLPASSLP2HP Allpass for lowpass to highpass frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSLP2HP(Wo,Wt) returns numerator,
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
%        % Allpass mapper changing the lowpass to highpass with the cutoff
%        % frequency originally at Wo=0.5 moved to to Wt=0.25
%        Wo = 0.5;
%        Wt = 0.25;
%        [AllpassNum, AllpassDen] = allpasslp2hp(Wo, Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, abs(angle(h))/pi, Wt, Wo, 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2HP and ZPKLP2HP.

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
%   $Revision: 1.2 $  $Date: 2002/04/14 15:41:44 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,2,nargin));

error(ftransfargchk(wo, 'Frequency value from the prototype filter', ...
                        'real', 'scalar', 'normalized'));
error(ftransfargchk(wt, 'Desired frequency location in the target filter', ...
                        'real', 'scalar', 'normalized'));

% ---------------------------------------------------------------------
% Calculate the mapping filter

alpha      = - cos(pi*(wo+wt)/2) / cos(pi*(wo-wt)/2);
allpassnum = [-1     -alpha];
allpassden = [ alpha  1];