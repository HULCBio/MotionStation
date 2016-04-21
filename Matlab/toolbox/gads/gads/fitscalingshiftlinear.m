function expectations = fitscalingshiftlinear(scores,nParents,MaximumSurvivalRate)
%FITSCALINGSHIFTLINEAR Offset and scale fitness to desired range.
%   EXPECTATION = FITSCALINGSHIFTLINEAR(SCORES,NPARENTS,MAXIMUMSURVIVALRATE)
%   calculates the EXPECTATION using the SCORES, number of parents NPARENTS, 
%   and a survival rate MAXIMUMSURVIVALRATE.
%
%   MAXIMUMSURVIVALRATE is the ratio of the expectation of the best
%   individual to the average expectation of the population. Values near 2
%   have been found to work well. The default value is 2.
%
%   Example:
%   Create an options structure that will use FITSCALINGSHIFTLINEAR as the
%   fitness scaling function and use a default survival rate 
%      options = gaoptimset('FitnessScalingFcn',@fitscalingshiftlinear);  
%   Specify a MAXIMUMSURVIVALRATE of 4
%      maximumsurvivalrate = 4;
%      options = gaoptimset('FitnessScalingFcn', ...
%             {@fitscalingshiftlinear, maximumsurvivalrate});
%   
%   See also GAOPTIMSET, GA, FITSCALINGRANK, FITSCALINGPROP, FITSCALINGTOP.

%   Like all fitness scaling functions, expectations must sum to nParents.
%   We try to find an offset and scaling factor that meets this
%   requirement AND has the expectation of the fittest individual equal to
%   MAXIMUMSURVIVALRATE times the mean.
%
%   It may not be possible to do this and assure that all expectations are
%   non-negative. In this case, we can only meet the sum and non-negative
%   requirements.


%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2004/01/16 16:51:43 $


if(nargin < 3)
    MaximumSurvivalRate = 2;
end

% We're MINIMIZING here
scores = -scores;

maxScore  = max(scores);
meanScore = mean(scores);
minScore  = min(scores);

if(~finite(meanScore))
    error('gads:FITSCALINGGOLDBERG:finiteScore','Linear Fitness Scaling requires FINITE score values.');
end

% Take care of the degenerate case where all scores are the same
if(maxScore == minScore)
    expectations = ones(length(scores),1) ./ length(scores);
    return;
end

% Since we must sum to nParents, our mean must be this:
desiredMean = nParents/length(scores);

% We want to find a scale and an offset so that:
% 1. scale * max + offset = MaximumSurvivalRate * desiredMean
% and
% 2.  Scale * mean + offset = desiredMean 
% Subtracting 2 from 1, Factoring out scale and desiredMean, and dividing
% both sides by max - mean gives:
scale = desiredMean * (MaximumSurvivalRate  - 1) / (maxScore - meanScore);

% offset so that the mean is desiredMean
offset = desiredMean - (scale * meanScore);

% if the above causes the least fitness to go negative,
% change our goal to have a min of zero & mean of nParents/length(scores)
if(offset + scale * minScore < 0)
    scale = desiredMean / (meanScore - minScore);
    offset = desiredMean - (scale * meanScore);
end

expectations = offset + scale * scores;



