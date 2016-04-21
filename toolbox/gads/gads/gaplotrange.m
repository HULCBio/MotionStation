function state = gaplotrange(options,state,flag)
%GAPLOTRANGE Plots the min, mean, and max of the scores.
%   STATE = GAPLOTRANGE(OPTIONS,STATE,FLAG) plots the min, mean, and max of
%   of the scores.  
%
%   Example:
%   Create an options structure that uses GAPLOTRANGE
%   as the plot function
%     options = gaoptimset('PlotFcns',@gaplotrange);

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/04 03:24:28 $

persistent scoreStats;

if isinf(options.Generations)
    pos = get(gca,'Position');
    title('Plot Not Available');
    return;
end

if(strcmp(flag,'beginning'))
     scoreStats = zeros(3,1+options.Generations);
end

generation = state.Generation;
score = state.Score;
smean = mean(score);
smax = max(score);
smin = min(score);

set(gca,'NextPlot','replacechildren');
scoreStats(:,1 + generation) = [smean;smean - smin;smax - smean];
range =1:(generation + 1);
errorbar(range,scoreStats(1,range),scoreStats(2,range),scoreStats(3,range))


title('Best, Worst, and Mean Scores')
xlabel generation
