function stop = psplotfuncount(optimvalues,flag)
%PSPLOTFUNCOUNT: Plot function evaluations every iteration.
%   STOP = PSPLOTFUNCOUNT(OPTIMVALUES,FLAG) where OPTIMVALUES is a
%   structure with the following fields: 
%              x: current point X
%      iteration: iteration count
%           fval: function value
%       meshsize: current mesh size
%      funccount: number of function evaluations
%         method: method used in last iteration
%         TolFun: tolerance on function value in last iteration
%           TolX: tolerance on X value in last iteration
%
%   FLAG: Current state in which PlotFcn is called. Possible values are:
%           init: initialization state
%           iter: iteration state
%           done: final state
%
%   STOP: A boolean to stop the algorithm.
%
%   See also PATTERNSEARCH, GA, PSOPTIMSET.


%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2004/04/06 01:10:00 $

stop = false;
hold on;
if(strcmp(flag,'init'))
    setappdata(gcf,'data',optimvalues.funccount);
    grid on;
    xlabel('Iteration'); ylabel('Function count per interval');
end
if strcmpi('iter',flag)
    totalFunCount = getappdata(gcf,'data');
    plot(optimvalues.iteration, (optimvalues.funccount -totalFunCount),'kd','MarkerSize',5,'MarkerFaceColor',[1 0 1]);
    setappdata(gcf,'data',optimvalues.funccount);
    title(['Total Function Count: ',num2str(optimvalues.funccount)]);
end
hold off;
