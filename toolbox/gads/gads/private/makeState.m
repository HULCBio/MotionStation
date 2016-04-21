function state = makeState(GenomeLength,FitnessFcn,options)
%MAKESTATE Create an initial population and fitness scores
%   state = makeStates(GenomeLength,FitnessFcn,options) Creates an initial 
%   state structure using the information in the options structure.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2004/01/16 16:50:01 $

if(isempty(options.InitialPopulation)) % we have to make the initial pop.
    state.Population = feval(options.CreationFcn,GenomeLength,FitnessFcn,options,options.CreationFcnArgs{:});
else % the initial pop was passed in!
    state.Population = options.InitialPopulation;
end

if(isempty(options.InitialScores))
    % score each member of the popultion
if strcmpi(options.Vectorized, 'off')
    state.Score = feval(@fcnvectorizer,state.Population,FitnessFcn,options.FitnessFcnArgs{:});
else
    state.Score = feval(FitnessFcn,state.Population,options.FitnessFcnArgs{:});
end 

else
    state.Score = options.InitialScores;
    options.InitialScores = [];
end

% a variety of data used in various places
state.Generation = 0;		% current generation counter
state.StartTime = cputime;	% duh
state.StopFlag = []; 		% reason for termination
state.LastImprovement = 1;	% generation stall counter
state.LastImprovementTime = state.StartTime;	% time stall counter
state.Selection = [];

