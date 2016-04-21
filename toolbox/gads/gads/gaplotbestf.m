function state = gaplotbestf(options,state,flag)
%GAPLOTBESTF Plots the best score and the mean score.
%   STATE = GAPLOTBESTF(OPTIONS,STATE,FLAG) plots the best score as well
%   as the mean of the scores.
%
%   Example:
%    Create an options structure that will use GAPLOTBESTF
%    as the plot function
%     options = gaoptimset('PlotFcns',@gaplotbestf);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/04 03:24:23 $

if(strcmp(flag,'init'))
    set(gca,'xlim',[1,options.Generations]);
    xlabel Generation
    ylabel('Fitness value');
end

hold on;
generation = state.Generation;
best = min(state.Score);
plot(generation,best, '.k');
m = mean(state.Score);
plot(generation,m,'.b');
title(['Best: ',num2str(best),' Mean: ',num2str(m)])
hold off;
        
