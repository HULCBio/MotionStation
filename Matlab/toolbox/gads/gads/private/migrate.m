function state = migrate(FitnessFcn,GenomeLength,options,state )
%MIGRATE Migrate members between sub-populations.
%   state = migrate(FitnessFcn,GenomeLength,options,state ); migrates individuals between
%   subpopulations.
%
%   migrationInterval: If the population size property is a vector
%   of scalars, then there will be multiple, independent populations,
%   evolving separately. Every so often, the best individuals
%   from one sub-population will replace the worst individuals in
%   another sub-population. The migration interval controls how
%   many generation pass between migration. If migrationInterval
%   equals 20, for example, migration between subpopulations will
%   take place every 20 generations.
%
%   migrationFraction: When migration occurs between sub-populations
%   this parameter controls how many individuals move between
%   populations. This is the fraction of the lesser of the two populations
%   that moves. If members are migrating from a sub-population
%   of 50 individuals into a population of 100 individuals and the
%   migrationFraction is 0.1, then 5 individuals (0.1 * 50) will move.
%   Individuals that migrate from one sub-population to another are copied. 
%   They are not removed from the source sub-population.
%
%   migrationDirection: Migration can take place in one direction or two.
%   If migration direction is set to "forward" then migration takes place
%   toward the last sub-population. That is the nth sub-population
%   migrates into the (n+1)'th sub-population. If migration direction is
%   both then the nth sub-population migrates into both the (n-1)th
%   and the (n+1)th sub-population. Migration wraps at the ends of
%   the sup-populations. That is, the last sub-population migrates
%   into the first, and the first may migrate into the last. To prevent
%   wrapping, specify a sub-population of size zero.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2004/01/16 16:50:02 $

% is it time for migration to occur?
if((length(options.PopulationSize) == 1) || rem(state.Generation,options.MigrationInterval) ~= 0)
    return
end

populations = options.PopulationSize;
subPops = populationIndicies(populations);

% How many will migrate from each sub-population?
nMigrators = round(populations * options.MigrationFraction);
% the min of the source and destination populations
forward  = min(nMigrators,[nMigrators(2:end),nMigrators(1)]);
backward = forward([end,1:(end-1)]);

% get sorted indicies for each sub-population
indicies = cell(1,length(populations));
newcomers = cell(1,length(populations));

% one pass to find who moves out from each subpopulation
for pop = 1:length(populations)
    p = subPops(:,pop);

    % get a set of indicies into this sub-population sorted by score
    [unused,i] = sort(state.Score(p(1):p(2)));
    sourcePop = i(:) + p(1) - 1;
    
    % where are we migrating to?
    ahead = 1 + mod(pop,length(populations));  
    newcomers{ahead} = [newcomers{ahead};sourcePop(1:forward(pop))]; 
    
    if(strcmpi(options.MigrationDirection,'both'))
        behind = 1 + mod(pop-2,length(populations));
        newcomers{behind} = [newcomers{behind}; sourcePop(1:backward(pop))];
    end
    
    indicies{pop} = sourcePop;
end

% a second pass to move them into each subpopulation.
for i = 1:length(populations)
    from = newcomers{i};
    % who is being replaced
    pop = indicies{i};
    n = length(from);
    to = pop((end-n + 1):end);
    %migrate
    state.Population(to,:) = state.Population(from,:);
    state.Score(to) = state.Score(from);
end


