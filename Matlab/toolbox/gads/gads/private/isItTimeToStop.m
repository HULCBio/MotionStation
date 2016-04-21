function reasonToStop = isItTimeToStop(options,state)
% Check to see if any of the stopping criteria have been met.
%   isItTimeToStop(options,state); is a string containing the reason the ga
%   should be stopped. The empty string means that it is not time to stop.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2004/03/09 16:15:50 $

if  any(strcmpi(options.Display, {'iter','diagnose'}))
    Gen      = state.Generation; 
    FunEval  = Gen*length(state.Score);
    BestFval = state.Best(Gen);
    MeanFval = mean(state.Score);
    StallGen = Gen  - state.LastImprovement;
    fprintf('%5.0f         %5.0f    %12.4g    %12.4g    %5.0f\n', ...
        Gen, FunEval, BestFval, MeanFval, StallGen);
end
reasonToStop = [];
if(state.Generation >= options.Generations)
    reasonToStop = sprintf(['Optimization terminated: ','maximum number of generations exceeded.']);
elseif((cputime-state.StartTime) > options.TimeLimit)
    reasonToStop = sprintf(['Optimization terminated: ','time limit exceeded.']);
elseif((cputime-state.LastImprovementTime) > options.StallTimeLimit)
    reasonToStop = sprintf(['Optimization terminated: ','stall time limit exceeded.']);
elseif((state.Generation  - state.LastImprovement) > options.StallGenLimit)
    reasonToStop = sprintf(['Optimization terminated: ','stall generations limit exceeded.']);
elseif(min(min(state.Score)) <= options.FitnessLimit )
    reasonToStop = sprintf(['Optimization terminated: ','minimum fitness limit reached.']);
elseif(~isempty(state.StopFlag))
    reasonToStop = sprintf(['Optimization terminated: ',state.StopFlag]);
end

if ~isempty(reasonToStop) && any(strcmpi(options.Display, {'iter','diagnose','final'}))
    fprintf('%s\n',reasonToStop);
end