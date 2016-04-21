function [allpassnum, allpassden] = allpasslp2bpc(wo, wt)
%ALLPASSLP2BPC Allpass for lowpass to complex bandpass frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSLP2BPC(Wo,Wt) returns numerator,
%   ALLPASSNUM, and the denominator, ALLPASSDEN, of the allpass mapping filter.
%
%   Inputs:
%     Wo         - Frequency value to be transformed from the prototype filter.
%                  The frequency should be normalized to be between 0 and 1,
%                  with 1 corresponding to half the sample rate.
%     Wt         - Desired frequency location in the transformed target filter.
%                  The frequency should be normalized to be between -1 and 1,
%                  with 1 corresponding to half the sample rate.
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Example:
%        % Allpass mapper changing the lowpass with cutoff frequency originally
%        % at Wo=0.5 to the complex bandpass with bandedges at Wt1=0.2 nad Wt2=0.4
%        Wo = 0.5;
%        Wt = [0.2,0.4];
%        [AllpassNum, AllpassDen] = allpasslp2bpc(Wo, Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, angle(h)/pi, Wt, Wo.*[-1,1], 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2BPC and ZPKLP2BPC.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:41:35 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,2,nargin));

error(ftransfargchk(wo, 'Frequency value from the prototype filter', ...
                        'scalar',  'real', 'normalized'));
error(ftransfargchk(wt, 'Desired frequency location in the target filter', ...
                        'vector2', 'real', 'full normalized'));

% ---------------------------------------------------------------------
% Calculate the mapping filter

wc         = sum(wt) / 2;
bw         = max(wt) - min(wt);
alpha      = sin(pi*(wo-bw/2)/2) / sin(pi*(wo+bw/2)/2);
beta       = exp(-pi*i*wc);
allpassnum = [       beta -alpha];
allpassden = [-alpha*beta  1];
