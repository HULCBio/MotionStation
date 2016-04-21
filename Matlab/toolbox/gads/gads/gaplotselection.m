function state = gaplotselection(options,state,flag)
%GAPLOTSELECTION A histogram of parents.
%   STATE = GAPLOTSELECTION(OPTIONS,STATE,FLAG) plots a histogram of the
%   parents. This will let you see which parents are contributing to each 
%   generation. If there is not enough spread (only a few parents are being 
%   used) then you may want to change some parameters to get more diversity.
%
%   Example:
%    Create an options structure that uses GAPLOTSELECTION
%    as the plot function
%      options = gaoptimset('PlotFcns',@gaplotselection);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/04 03:24:31 $

if(strcmp(flag,'iter'))
    hist(state.Selection);
    name = func2str(options.SelectionFcn);
    title([name,' Selection'])
    xlabel('Individual')
    ylabel('Number of children')
end
