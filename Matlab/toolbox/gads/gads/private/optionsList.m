function p = optionsList(choice)
%OPTIONSLIST List of all GA and PS options.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/03/09 16:15:52 $

p = [];
switch lower(choice)
    case 'ga'
        p = {
            'PopulationType'
            'PopInitRange'
            'PopulationSize'
            'EliteCount'
            'CrossoverFraction'
            'MigrationDirection'
            'MigrationInterval'
            'MigrationFraction'
            'Generations'
            'TimeLimit'
            'FitnessLimit'
            'StallGenLimit'
            'StallTimeLimit'
            'InitialPopulation'
            'InitialScores'
            'PlotInterval'
            'FitnessScalingFcn'
            'SelectionFcn'
            'CrossoverFcn'
            'MutationFcn'
            'Display'
            'PlotFcns'
            'OutputFcns'
            'CreationFcn'
            'HybridFcn'
            'Vectorized'
        };
        
    case 'ps'
        p = {
            'TolMesh'
            'TolX'
            'TolFun'
            'TolBind'
            'MaxIteration'
            'MaxFunEvals'
            'MeshContraction'
            'MeshExpansion'
            'MeshAccelerator'
            'MeshRotate'
            'InitialMeshSize'
            'ScaleMesh'
            'MaxMeshSize'
            'PollMethod'
            'CompletePoll'
            'PollingOrder'
            'SearchMethod'
            'CompleteSearch'
            'Display'
            'OutputFcns'
            'PlotFcns'
            'PlotInterval'
            'Cache'
            'CacheSize'
            'CacheTol'
            'Vectorized'
        };
end
