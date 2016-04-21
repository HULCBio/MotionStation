%COMMBLKDFEEQLMS
% Mask error checks for the LMS DFE block

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/30 02:48:24 $

% check the number of forward taps
if ~isscalar(nFwdTaps) || nFwdTaps <1 || floor(nFwdTaps) ~= nFwdTaps || ~isnumeric(nFwdTaps)  
      error('commblks:dfeeqlms:nfwdTaps',...
          'Number of forward taps must be a scalar integer greater than 0.');
end

% check the number of feedback taps
if ~isscalar(nFdbkTaps) || nFdbkTaps <1 || floor(nFdbkTaps) ~= nFdbkTaps || ~isnumeric(nFdbkTaps)  
          error('commblks:dfeeqlms:nfdbkTaps',...
              'Number of feedback taps must be a scalar integer greater than 0.');
end

nTaps = nFwdTaps + nFdbkTaps;

% check the number of samples per symbol
if   ~isscalar(nSamp) || nSamp <1 || floor(nSamp) ~= nSamp || ~isnumeric(nSamp)
    error('commblks:dfeqlms:nSamp',...
        'Number of samples per symbols must be a scalar integer greater than 0.');
end

%check the signal constellation
if ~isnumeric(sigConst) || ~isvector(sigConst)
    error('commblks:dfeqlms:sigConst',...
        'The signal constellation must be a 1-D vector.');
end

%ensure that the signal constellation is a complex number
sigConst = complex(real(sigConst),imag(sigConst));

% check the reference tap
if  ~isscalar(delay) || delay <1 || delay>nFwdTaps || floor(delay) ~= delay || ~isnumeric(delay) 
    error('commblks:dfeqlms:refTap',...
        'The reference tap must be a scalar integer greater than 0 and less than the number of Taps.');
end
% check that the reference tap -1 is an integer multpiple of nSamp
if(rem(delay-1,nSamp) ~= 0 )
    error('commblks:lineqlms:refTapNsamp',...
        'Reference tap - 1 must be a scalar multiple of the number of samples per symbol.');
end
    
% adjust the delay based on the number of samples per symbol
delay = floor((delay-1)/nSamp) +1;


%check the leakage
if  ~isscalar(leakage) || leakage <0 || leakage>1 || ~isnumeric(leakage) 
    error('commblks:dfeqlms:leakage',...
        'Leakage must be between 0 and 1.');
end


if ~isscalar(stepSize) || stepSize <0 ||  ~isnumeric(stepSize) 
    error('commblks:dfeqlms:stepsize',...
        'The stepsize must be greater than 0.');
end

%check the initial weights, expand them if scalar.
if ~ any(isnumeric(initWeights) )
      error('commblks:dfeqlms:initweights',...
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


