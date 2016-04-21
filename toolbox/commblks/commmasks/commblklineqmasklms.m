%COMMBLKLINEQMASKLMS
% Mask error checks for the LMS Linear Equalizer block

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:02:56 $

% check the number of taps
if ~isscalar(nTaps)|| nTaps <1 || floor(nTaps) ~= nTaps || ~isnumeric(nTaps)
    error('commblks:lineqlms:nTaps',...
        'Number of taps must be a scalar integer greater than 0.');
end

nFwdTaps = nTaps;
% check the number of samples per symbol
if  ~isscalar(nSamp) || nSamp <1 || floor(nSamp) ~= nSamp || ~isnumeric(nSamp)
    error('commblks:lineqlms:nSamp',...
        'Number of samples per symbols must be a scalar integer greater than 0.');
end

%check the signal constellation
if ~isnumeric(sigConst) || ~isvector(sigConst)
    error('commblks:lineqlms:sigConst',...
        'The signal constellation must be a 1-D vector.');
end
%ensure that the signal constellation is a complex number
sigConst = complex(real(sigConst),imag(sigConst));

if exist('delay','var') % CMA does not have delay var
    % check the reference tap
    if ~isscalar(delay) || delay <1 || delay>nTaps || floor(delay) ~= delay || ~isnumeric(delay)
        error('commblks:lineqlms:refTap',...
            'The reference tap must be a scalar integer greater than 0 and less than the number of Taps.');
    end
    % check that the reference tap -1 is an integer multpiple of nSamp
    if(rem(delay-1,nSamp) ~= 0 )
        error('commblks:lineqlms:refTapNsamp',...
            'Reference tap - 1 must be a scalar multiple of the number of samples per symbol.');
    end

    % adjust the delay based on the number of samples per symbol
    delay = floor((delay-1)/nSamp) +1;
end
%check the leakage
if leakage <0 || leakage>1 || ~isnumeric(leakage) || ~isscalar(leakage)
    error('commblks:lineqlms:leakage',...
        'Leakage must be between 0 and 1.');
end

%check the stepsize
if stepSize <0 ||  ~isnumeric(stepSize) || ~isscalar(stepSize)
    error('commblks:lineqlms:stepsize',...
        'The stepsize must be greater than 0.');
end

%check the initial weights, expand them if scalar.
if ~ any(isnumeric(initWeights) )
    error('commblks:lineqlms:initweights',...
        'The initial weights must be numeric.');
end

if isscalar(initWeights)
    initWeights = initWeights*ones(1,nTaps);
else
    if length(initWeights) ~= nTaps
        error('commblks:lineqlms:leninitweights',...
            'The length of the initial weights must equal the number of filter taps.');
    end
end


