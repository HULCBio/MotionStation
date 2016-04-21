function state = gaplotgenealogy(options,state,flag,purge)
%GAPLOTGENEALOGY Plots the ancestors of every individual.
%   STATE = GAPLOTGENEALOGY(OPTIONS,STATE,FLAG,PURGE) plots the ancestors
%   of every individual. It is often useful to look at where each member 
%   of a population comes from. You can see the relative contributions of 
%   elites, crossovers and mutations. As a diagnostic tool, these charts
%   can help you spot problems in your algorithm.
% 	
%   Mutation is shown in red, elites in Black and crossover in blue.
% 	
%   If PURGE == 0 then all individuals are shown. If PURGE == 1 then
%   individuals that do not contribute to the last generation are removed.
%   If PURGE == 2 the individuals that do not contribute to the best
%   individual in the last generation are removed.
%
%   Example:
%    Create an options structure that uses GAPLOTGENEALOGY
%    as the plot function, with the default value of PURGE (zero)
%      options = gaoptimset('PlotFcns', @gaplotgenealogy );
%    Create an options structure that uses GAPLOTGENEALOGY
%    as the plot function, with 1 as the value of PURGE
%     purge = 1;
%     options = gaoptimset('PlotFcns', {@gaplotgenealogy, purge});
%
%   NOTE: This plot is only available after the GA has stopped.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/04 03:24:27 $

persistent data;

if(nargin < 4)
    purge = 0;
end

if isinf(options.Generations)
    pos = get(gca,'Position');
    title('Plot Not Available');
    return;
end
if(strcmp(flag,'init'))
    % allocate
    clear data;
    xlabel('Genealogy will be displayed at the end of the run')
elseif(strcmp(flag,'iter'))
    %store
    if(isempty(data))
        data = zeros(length(state.Selection),options.Generations);
    end
    
    data(:,state.Generation) = state.Selection;
else
    makeChart(data,options,state,purge)
end

function makeChart(data,options,state,purge)

% how many of each type.
nEliteKids = options.EliteCount;
nXoverKids = round(options.CrossoverFraction * (options.PopulationSize - nEliteKids));
nMutateKids = options.PopulationSize - nEliteKids - nXoverKids;

[parent,gen] = size(data);

if(purge > 0)
    
    % clear out everything from the last column except those that made the
    % best
    if(purge > 1)
        last = zeros(parent,1);
        [unused,i] = min(state.Score);
        if(i <= nEliteKids)
            last(i) = data(i,gen);
        elseif(i <= (nEliteKids + nXoverKids))
            index = i * 2 - nEliteKids  -1;
            last(index) = data(index,gen);
            last(index+ 1) = data(index+ 1,gen);
        else
            last(i + nXoverKids) =  data(i + nXoverKids,gen);
        end
        data(:,gen) = last;
    end

% remove non-survivors
for col = (gen-1):-1:1 % work backwards through the generations
        for individual = 1:options.PopulationSize
            if(~any(data(:,col+1) == individual)) % if this individual is unreferenced in the next gen
                if(individual <= nEliteKids)
                    data(individual,col) = 0;
                elseif(individual <= (nEliteKids + nXoverKids))
                    index = individual * 2 -nEliteKids  -1;
                    data(index,col) = 0;
                    data(index+1,col) = 0;
                else
                    data(individual + nXoverKids,col) = 0;
                end
            end
        end
    end
end

cla
hold on

% Elite
for i = 2:gen
    x = [i-1,i];
    c = data(:,i);
    
    for j = 1:nEliteKids
        if(c(j) ~= 0)
            plot(x,[c(j),j],'k')
            plot(i,j,'k.')
        end
    end
    start = nEliteKids + 1;
    
    % crossover
    for j = 1:nXoverKids
        index = start + (j-1) * 2;
        if(c(index) ~= 0)
            y = j + nEliteKids;
            plot(x,[c(index    ),y],'b')
            plot(x,[c(index + 1),y],'b')
            plot(i,y,'b.')
        end
    end
    
    start = nEliteKids + 2 * nXoverKids;
    
    % mutation
    for j = 1:nMutateKids
        index = start + j;
        y = j + nEliteKids + nXoverKids;
        if(c(index) ~= 0)
            plot(x,[c(index),y],'r')
            plot(i,y,'r.')
        end
    end
end

xlabel('Generation')
ylabel('Individual')
set(gca,'ylim',[0,options.PopulationSize+1])
hold off
