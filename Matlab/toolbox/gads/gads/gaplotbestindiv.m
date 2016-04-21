function state = gaplotbestindiv(options,state,flag)
%GAPLOTBESTINDIV Plots the best individual.
%   STATE = GAPLOTBESTINDIV(OPTIONS,STATE,FLAG) plots the best 
%   individual's genome as a histogram, with the number of bins
%   in the histogram equal to the length of the genome.
%
%   Example:
%    Create an options structure that uses GAPLOTBESTINDIV
%    as the plot function
%     options = gaoptimset('PlotFcns',@gaplotbestindiv);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/04 03:24:24 $

GenomeLength = size(state.Population,2);
if(strcmp(flag,'init'))
  title('Current Best Individual')
  xlabel(['Number of variables (',num2str(GenomeLength),')']);
  ylabel('Current best individual');
end
[unused,i] = min(state.Score);
h = bar(double(state.Population(i,:)));
set(h,'edgec','none')
set(gca,'xlim',[0,1 + GenomeLength])

