function [ber, interval] = berconfint(nErrs, nTrials, level)
%BERCONFINT BER and confidence interval of Monte Carlo simulation.
%   [BER INTERVAL] = BERCONFINT(NERRS, NTRIALS) returns the error
%   probability BER and the confidence interval INTERVAL with 95%
%   confidence for a Monte Carlo simulation of NTRIALS trials with NERRS
%   errors.
%
%   [BER INTERVAL] = BERCONFINT(NERRS, NTRIALS, LEVEL) returns the error
%   probability BER and the confidence interval INTERVAL with confidence
%   level LEVEL for a Monte Carlo simulation of NTRIALS trials with NERRS
%   errors.
% 
%   See also BINOFIT, MLE (Statistics Toolbox).

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:00:28 $

if (nargin < 2)
    error('comm:berconfint:minArgs', 'BERCONFINT requires at least 2 arguments.');
elseif (~is(nErrs, 'nonnegative') || ~is(nErrs, 'integer') || ...
        ~is(nTrials, 'nonnegative') || ~is(nTrials, 'integer'))
    error('comm:berconfint:intArgs', 'NERRS and NTRIALS must be nonnegative integers.');
elseif (nargin == 2)
    [ber interval] = binofit(nErrs, nTrials);
elseif (~is(level, 'real') || any(level<0) || any(level>1))
    error('comm:berconfint:level', 'Confidence level must be between 0 and 1.');
else
    [ber interval] = binofit(nErrs, nTrials, 1-level);
end
