function state = gaplotscores(options,state,flag)
%GAPLOTSCORES Plots the scores of every member of the population.
%   STATE = GAPLOTSCORES(OPTIONS,STATE,FLAG) plots the scores of  every
%   member of the population. The individuals are ordered as follows.  The
%   first (leftmost) n individuals are the elites (by default 2), these will
%   always be the lowest scores. The next (Middle) group is the individuals
%   that were created by crossover and finally the last (rightmost) group
%   are those individuals created by mutation.
%
%   You can get an idea of the relative behavior of each of these groups. 
%   In particular you can gauge the relative contributions of mutation and
%   crossover and adjust the crossover fraction accordingly.
%
%   If you are using multiple populations, this entire pattern will be
%   repeated in a different color for each subpopulation. You can see which
%   population is outperforming the others and watch the effects of migration
%   between subpopulations.
%
%   Example:
%    Create an options structure that uses GAPLOTSCORES
%    as the plot function
%      options = gaoptimset('PlotFcns',@gaplotscores);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/04 03:24:30 $

% we would like the ylimits on this bar chart to never increase. This
% provides for a less jumpy display. To do this, we keep track of the
% lowest that the upper y limit has ever been, and prevent the limit from
% rising above that. maxLim is the bound.
persistent maxLim;
if(strcmp(flag,'init'))
    maxLim = inf;
end

colors = ['r','b','g','y','m','c'];
subPops = populationIndicies(options.PopulationSize);
[unused,c] = size(subPops);
 set(gca,'NextPlot','replacechildren');
for i = 1:c
    pop = subPops(:,i);
    range = pop(1):pop(2);
    h = bar(range,state.Score(range),colors(1 + mod(i,5)));
    set(h,'edgec','none','facecolor',colors(1 + mod(i,5)))
   hold on
end
hold off
title('Fitness of Each Individual')

% constrain the upper y limit.
ylim = get(gca,'ylim');
maxLim = min(maxLim,ylim(2));
ylim(2) = min(maxLim,ylim(2));

% make the x axis span exactly the data, and that ylim never increases.
set(gca,'xlim',[0,1 + sum(options.PopulationSize)],'ylim',ylim)

