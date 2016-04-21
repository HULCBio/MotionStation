function state = gaplotexpectation(options,state,flag)
%GAPLOTEXPECTATION Plots raw scores against the expected number of offspring.
%   STATE = GAPLOTEXPECTATION(OPTIONS,STATE,FLAG) plots the raw scores
%   against the expected number of offspring.
%
%   Example:
%    Create an options structure that uses GAPLOTEXPECTATION
%    as the plot function
%     options = gaoptimset('PlotFcns',@gaplotexpectation);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/04 03:24:26 $

% we have to store scores because the expectation in the state are for the
% last generation and the scores are for the next generation.
persistent scores;

if(strcmp(flag,'init'))
    scores = state.Score;
else
    if length(state.Score) ~= length(state.Expectation)
        scores = state.Score(length(state.Score)-length(state.Expectation)+1:end);
    end
    plot(scores,state.Expectation,'.');
    xlabel('Raw scores');
    ylabel('Expectation');
    name = func2str(options.FitnessScalingFcn);
    title([name,' Fitness Scaling'])
    scores = state.Score;
end
