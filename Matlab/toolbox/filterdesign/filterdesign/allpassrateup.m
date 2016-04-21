function [allpassnum, allpassden] = allpassrateup(N)
%ALLPASSRATEUP Allpass for integer upsample frequency transformation.
%   [AllpassNum,AllpassDen] = ALLPASSRATEUP(N) returns numerator, ALLPASSNUM,
%   and denominator, ALLPASSDEN, vectors of the allpass mapping filter.
%
%   Inputs:
%     N          - The frequency replication ratio (upsampling ratio)
%   Outputs:
%     AllpassNum - Numerator of the mapping filter
%     AllpassDen - Denominator of the mapping filter
%
%   Example:
%        % Allpass mapper creating the effect of upsampling the digital filter by 4
%        N = 4;
%        Wo = 0.2;                % Selected feature of the original filter
%        Wt = Wo/N + 2*[0:N-1]/N;
%        [AllpassNum, AllpassDen] = allpassrateup(4);
%        % Calculate the spectrum of the allpass mapping filter
%        [h, f] = freqz(AllpassNum, AllpassDen, 'whole');
%        % Plot the phase response normalised to PI as a mapping function Wo(Wt)
%        plot(f/pi, angle(h)/pi, Wt, Wo.*[1,1,1,1], 'ro');
%        title('The mapping function Wo(Wt)');
%        xlabel('New frequency, Wt');
%        ylabel('Old frequency, Wo');
%
%   See also IIRRATEUP and ZPKRATEUP.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:42:02 $

% --------------------------------------------------------------------
% Perform the parameter validity check

error(nargchk(1,1,nargin));

error(ftransfargchk(N, 'Upsampling ratio', 'real', 'scalar', 'int', 'positive'));

% ---------------------------------------------------------------------
% Calculate the mapping filter

allpassnum = [1 zeros(1,N)];
allpassden = [zeros(1,N) 1];