%COMMBLKLINEQMASKVARLMS
% Mask error checks for the Variable Step LMS Equalizer blocks

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/01 18:59:35 $

% this mask helper function checks the block parameters specific to the
% variable step lms algorithm only. Error checks for the other parameters
% handled in commblklineqmasklms

% check the initial step size;
if ~isscalar(initMu)|| initMu <0 ||  ~isnumeric(initMu)
    error('commblks:varlms:initMu',...
        'The initial stepsize must be a scalar greater than 0.');
end

% check the increment step size;
if ~isscalar(incMu)|| incMu <0 ||  ~isnumeric(incMu)
    error('commblks:varlms:incMu',...
        'The increment stepsize must be a scalar greater than 0.');
end

% check the minimum step size;
if ~isscalar(minMu)|| minMu <0 ||  ~isnumeric(minMu)
    error('commblks:varlms:minMu',...
        'The minimum stepsize must be a scalar greater than 0.');
end


% check the maximum step size;
if ~isscalar(maxMu)|| maxMu <0 ||  ~isnumeric(maxMu)
    error('commblks:varlms:maxMu',...
        'The maximum stepsize must be a scalar greater than 0.');
end


%dummy variable so that commblklineqmasklms will not error out.
stepSize = 1;