function [allpassnum, allpassden] = allpassbpc2bpc(wo, wt)
%ALLPASSBPC2BPC Allpass for complex bandpass frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSBPC2BPC(Wo,Wt) returns numerator,
%   ALLPASSNUM, and the denominator, ALLPASSDEN, of the allpass mapping filter.
%
%   Inputs:
%     Wo         - Frequency values to be transformed from the prototype filter.
%     Wt         - Desired frequency locations in the transformed target filter.
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between -1 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        % Allpass mapper changing the complex bandpass with bandedges originally
%        % at Wo1=0.2 and Wo2=0.4 to the new bandedges at Wt1=0.3 nad Wt2=0.6
%        Wo = [0.2, 0.4];
%        Wt = [0.3, 0.6];
%        [AllpassNum, AllpassDen] = allpassbpc2bpc(Wo, Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, angle(h)/pi, Wt, Wo, 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRBPC2BPC and ZPKBPC2BPC.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:41:32 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,2,nargin));

error(ftransfargchk(wo, 'Frequency value from the prototype filter', ...
                        'vector2', 'real', 'full normalized'));
error(ftransfargchk(wt, 'Desired frequency location in the target filter', ...
                        'vector2', 'real', 'full normalized'));

% ---------------------------------------------------------------------
% Calculate the mapping filter

bw1        = max(wo) - min(wo);
bw2        = max(wt) - min(wt);
beta       = sin(pi*(bw1-bw2)/4)/sin(pi*(bw1+bw2)/4);
alpha      = exp(-j*pi*sum(wt)/2);
allpassnum = [      alpha -beta] * exp(j*pi*sum(wo)/2);
allpassden = [-beta*alpha  1];
