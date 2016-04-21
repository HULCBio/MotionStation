function state = gaplotdistance(options,state,flag)
%GAPLOTDISTANCE Averages several samples of distances between individuals.
%   STATE = GAPLOTDISTANCE(OPTIONS,STATE,FLAG) plots an averaged distance
%   between individuals.
%
%   Example:
%    Create an options structure that uses GAPLOTDISTANCE
%    as the plot function
%     options = gaoptimset('PlotFcns',@gaplotdistance);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/04 03:24:25 $

if(strcmp(flag,'init'))
    set(gca,'xlim',[1,options.Generations]);
    xlabel('Generation');
    title('Average Distance Between Individuals')
end
hold on;
samples = 20;
choices = ceil(sum(options.PopulationSize) * rand(samples,2));
population = state.Population;
distance = 0;
for i = 1:samples
    d = population(choices(i,1),:) - population(choices(i,2),:);
    distance = distance + sqrt( sum ( d.* d));
end
plot(state.Generation,distance/samples,'.');
hold off;
    
