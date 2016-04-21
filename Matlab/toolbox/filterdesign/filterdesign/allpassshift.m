function [allpassnum, allpassden] = allpassshift(wo, wt)
%ALLPASSSHIFT Allpass for real shift frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSSHIFT(Wo,Wt) returns numerator,
%   ALLPASSNUM, and denominator, ALLPASSDEN, vectors of the allpass
%   mapping filter.
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
%        % Allpass mapper precisely shifting one feature originally at 0.5 to 0.25
%        Wo = 0.5;
%        Wt = 0.25;
%        [AllpassNum, AllpassDen] = allpassshift(Wo, Wt);
%        % Calculate the spectrum of the mapping allpass filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, abs(angle(h))/pi, Wt, Wo, 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2LP and ZPKLP2LP.

%   Author(s): Dr. Artur Krukowski (consultant: Prof. G.D. Cain).
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:42:05 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,2,nargin));

error(ftransfargchk(wo, 'Frequency value from the prototype filter', ...
                        'real', 'scalar', 'normalized'));
error(ftransfargchk(wt, 'Desired frequency location in the target filter', ...
                        'real', 'scalar', 'normalized'));

% ---------------------------------------------------------------------
% Calculate the mapping filter

beta = cos(pi*(wo/2-wt));
if abs(beta) < 1.0,
   beta = beta / cos(pi*wo/2);
else
   beta = sin(pi*(wo/2-wt)) / sin(pi*wo/2);
end;
allpassnum = [1 -beta  0];
allpassden = [0  beta -1];