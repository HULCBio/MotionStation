%COMMBLKLINEQMASKRLS
% Mask error checks for the RLS Linear Equalizer block

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/01 18:59:33 $

% check the number of taps
if ~isscalar(nTaps)|| nTaps <1 || floor(nTaps) ~= nTaps || ~isnumeric(nTaps)
    error('commblks:lineqrls:nTaps',...
        'Number of taps must be a scalar integer greater than 0.');
end

nFwdTaps = nTaps;
% check the number of samples per symbol
if  ~isscalar(nSamp) || nSamp <1 || floor(nSamp) ~= nSamp || ~isnumeric(nSamp)
    error('commblks:lineqrls:nSamp',...
        'Number of samples per symbols must be a scalar integer greater than 0.');
end

%check the signal constellation
if ~isnumeric(sigConst) || ~isvector(sigConst)
    error('commblks:lineqrls:sigConst',...
        'The signal constellation must be a 1-D vector.');
end
%ensure that the signal constellation is a complex number
sigConst = complex(real(sigConst),imag(sigConst));

% check the reference tap
if ~isscalar(delay) || delay <1 || delay>nTaps || floor(delay) ~= delay || ~isnumeric(delay)
    error('commblks:lineqrls:refTap',...
        'The reference tap must be a scalar integer greater than 0 and less than the number of Taps.');
end
% check that the reference tap -1 is an integer multpiple of nSamp
if(rem(delay-1,nSamp) ~= 0 )
    error('commblks:lineqrls:refTapNsamp',...
        'Reference tap - 1 must be a scalar multiple of the number of samples per symbol.');
end
    
% adjust the delay based on the number of samples per symbol
delay = floor((delay-1)/nSamp) +1;

%check the forgetting factor
if lambda <0 || lambda>1 || ~isnumeric(lambda) || ~isscalar(lambda)
    error('commblks:lineqrls:leakage',...
        'The forgetting factor must be between 0 and 1.');
end

%check the inverse correlation matrix. Must be a square matrix
% nTaps x nTaps
if ~isnumeric(invCorr) 
    error('commblks:lineqrls:invCorrNum', ...
        'The inverse correlation matrix must numeric.');
end
if size(invCorr) ~= [nTaps nTaps]
    error('commblks:lineqrls:invCorrSize',...
        'The inverse correlation matrix must be a matrix whose dimensions match the number of taps.');
end

% adjust the inverse correlation matrix by the forgetting factor. This is to compensate for the 1 sample 
% delay in the fliter. This ensures that the inverse correlation matrix is exactly what the user thinks
% it is at the beginning of the algorithm.
invCorr = invCorr * lambda;
    
%check the initial weights, expand them if scalar.
if ~ any(isnumeric(initWeights) )
    error('commblks:lineqrls:initweights',...
        'The initial weights must be numeric.');
end

if isscalar(initWeights)
    initWeights = initWeights*ones(1,nTaps);
else
    if length(initWeights) ~= nTaps
        error('commblks:lineqrls:leninitweights',...
            'The length of the initial weights must equal the number of filter taps.');
    end
end


