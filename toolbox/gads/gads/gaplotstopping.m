function state = gaplotstopping(options,state,flag)
%GAPLOTSTOPPING Display stopping criteria levels.
%   STATE = GAPLOTSTOPPING(OPTIONS,STATE,FLAG) plots the current percentage
%   of the various criteria for stopping.  
%
%   Example:
%    Create an options structure that uses GAPLOTSTOPPING
%    as the plot function
%      options = gaoptimset('PlotFcns',@gaplotstopping);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/04 03:24:32 $

gen = state.Generation / options.Generations;
time = (cputime-state.StartTime) / options.TimeLimit;
stallG = (state.Generation  - state.LastImprovement) / options.StallGenLimit;
stallS = (cputime-state.LastImprovementTime) / options.StallTimeLimit;

barh(100 * [stallS, stallG, time, gen ])
set(gca,'xlim',[0,100],'yticklabel',{'Stall (T)','Stall (G)','Time','Generation'})
xlabel('% of criteria met')
title('Stopping Criteria')
