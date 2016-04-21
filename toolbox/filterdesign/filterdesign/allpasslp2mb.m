function [allpassnum, allpassden] = allpasslp2mb(wo, wt, pass)
%ALLPASSLP2MB Allpass for lowpass to M-band frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSLP2MB(Wo,Wt,Pass) returns numerator,
%   ALLPASSNUM, and the denominator, ALLPASSDEN, of the allpass mapping filter.
%
%   Inputs:
%     Wo         - Frequency value to be transformed from the prototype filter.
%     Wt         - Desired frequency locations in the transformed target filter
%     Pass       - Choice of the passband or stopband at DC ('pass'/'stop')
%                  The default is 'pass'.
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Frequencies must be normalized to be between 0 and 1, with 1 corresponding
%   to half the sample rate.
%
%   Example:
%        % Allpass mapper changing the lowpass with cutoff frequency originally
%        % at Wo=0.5 to the multiband with bandedges at Wt=[1:2:9]/10
%        Wo = 0.5;
%        Wt = [1:2:9]/10;
%        [AllpassNum, AllpassDen] = allpasslp2mb(Wo, Wt);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, abs(angle(h))/pi, Wt, Wo, 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRLP2MB and ZPKLP2MB.

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

%   Author(s): Dr. Artur Krukowski (consultants: Prof. I. Kale and Prof. G.D. Cain) University of Westminster.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:41:50 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(2,3,nargin));

error(ftransfargchk(wo, 'Frequency value from the prototype filter', ...
                        'scalar', 'real', 'normalized'));
error(ftransfargchk(wt, 'Desired frequency location in the target filter', ...
                        'vector', 'real', 'normalized'));
if nargin == 3,
   error(ftransfargchk(pass, 'Parameter Pass', 'string', 'pass/stop'));
   switch(lower(pass)),
      case 'stop', pass =  1;
      case 'pass', pass =  -1;
   end;
else
   pass = -1;
end;

% ---------------------------------------------------------------------
% Calculate the mapping filter

Forder     = length(wt);
Wold       = pi * wo * (-1).^(0:Forder-1);
Wnew       = pi * wt(:).';
alpha      = sin(Wnew.'/2 * (Forder-2:-2:-Forder) - Wold.'/2 * ones(1,Forder));
allpassnum = [1 -sin(Forder * Wnew/2 - Wold/2) / alpha'];
allpassden = fliplr(allpassnum) * pass;
