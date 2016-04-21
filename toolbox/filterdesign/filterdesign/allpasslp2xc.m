function [allpassnum, allpassden] = allpasslp2xc(wo, wt)
%ALLPASSLP2XC Allpass for lowpass to complex N-point frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSLP2XC(Wo,Wt) returns numerator,
%   ALLPASSNUM, and denominator, ALLPASSDEN, of the allpass mapping filter.
%
%   Inputs:
%     Wo         - Frequency values to be transformed from the prototype filter
%     Wt         - Desired frequency locations in the transformed target filter
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between -1 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        % Allpass mapper moving three independent features Wo of the original real
%        % lowpass filter to arbitrary positive frequencies Wt of the target filter
%        Wo = [-0.2, 0.3, -0.7, 0.4];
%        Wt = [ 0.3, 0.5,  0.7, 0.9];
%        [AllpassNum, AllpassDen] = allpasslp2xc(Wo,Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, angle(h)/pi, Wt, Wo, 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2XC and ZPKLP2XC.

%   References:
%     [1] Krukowski A. and I. Kale, "High-order complex frequency transformations",
%         Internal report No. 27/2001, Applied DSP and VLSI Research Group,
%         University of Westminster.

%   Author(s): Dr. Artur Krukowski (consultant: Prof. I. Kale) University of Westminster.
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:25:17 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,2,nargin));

error(ftransfargchk(wo,                'Frequency value from the prototype filter', ...
                                       'vector', 'real', 'full normalized', 'even'));
error(ftransfargchk(wt,                'Desired frequency location in the target filter', ...
                                       'vector', 'real', 'full normalized', 'even'));
error(ftransfargchk([wo(:).';wt(:).'], 'Prototype and target frequencies', 'overlap'));

% Check for cross-overs of the frequencies
% ---------------------------------------------------------------------
% Calculate the mapping filter

% Find such initial rotation factor that has all the poles outside the unit circle
C = fminsearch(@xcopt,0,optimset('TolX',eps,'TolFun',eps,'Display','off'),wt,wo,1);
[Cost, allpassnum, allpassden] = xcopt(C, wt, wo, 2);

% Reverse the rotation factor if poles are found inside the unit circle
if ~isempty(find(abs(roots(allpassden)) < 1)),
   if C > 0, C = C - 1; else C = C + 1; end;
end;

% Find such C that gives the best match
C = fminsearch(@xcopt,C,optimset('TolX',eps,'TolFun',eps,'Display','off'),wt,wo,2);
[Cost, allpassnum, allpassden] = xcopt(C, wt, wo, 2);

if Cost>1e-5,
   warning(['Objective function converged to = ',num2str(Cost),' -> possible inaccuracies in the target filter.']);
end;