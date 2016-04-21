function [allpassnum, allpassden] = allpasslp2mbc(wo, wt)
%ALLPASSLP2MBC Allpass for lowpass to complex M-band frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSLP2MBC(Wo,Wt) returns numerator,
%   ALLPASSNUM, and the denominator, ALLPASSDEN, of the allpass mapping filter.
%
%   Inputs:
%     Wo         - Frequency value to be transformed from the prototype filter.
%                  The frequency should be normalized to be between 0 and 1,
%                  with 1 corresponding to half the sample rate.
%     Wt         - Desired frequency locations in the transformed target filter
%                  The frequency should be normalized to be between -1 and 1,
%                  with 1 corresponding to half the sample rate.
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Example:
%        % Allpass mapper changing the lowpass with cutoff frequency originally
%        % at Wo=0.5 to the complex multiband with bandedges at Wt=[-3+1:2:9]/10
%        Wo = 0.5;
%        Wt = [-0.3 -0.1 0.1 0.3];
%        [AllpassNum, AllpassDen] = allpasslp2mbc(Wo, Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, angle(h)/pi, Wt+(1-sign(Wt)), Wo.*[-1 1 -1 1], 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2MBC and ZPKLP2MBC.

%   References:
%     [1] Krukowski A. and I. Kale, "High-order complex frequency transformations",
%         Internal report No. 27/2001, Applied DSP and VLSI Research Group,
%         University of Westminster.

%   Author(s): Dr. Artur Krukowski (consultant: Prof. I. Kale) University of Westminster.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:41:53 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,2,nargin));

error(ftransfargchk(wo,     'Frequency value from the prototype filter', ...
                            'scalar', 'real', 'normalized'));
error(ftransfargchk(wt,     'Desired frequency location in the target filter', ...
                            'vector', 'real', 'full normalized', 'even'));
% ---------------------------------------------------------------------
% Calculate the mapping filter

N         = length(wt);
Wo(1:2:N) = -wo;
Wo(2:2:N) =  wo;
[allpassnum, allpassden] = allpasslp2xc(Wo, wt);