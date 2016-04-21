function stop = psplotbestf(optimvalues,flag)
%PSPLOTBESTF: PlotFcn to plot best function value.
%   STOP = PSPLOTBESTF(OPTIMVALUES,FLAG) where OPTIMVALUES is a structure
%   with the following fields:
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
%   $Revision: 1.12.4.1 $  $Date: 2004/04/06 01:09:58 $

stop = false;
hold on;
if(strcmp(flag,'init'))
    grid on;
    plot(optimvalues.iteration,optimvalues.fval, '.b');
    xlabel('Iteration'); ylabel('Function value')
end

if strcmpi(flag, 'iter')
    plot(optimvalues.iteration,optimvalues.fval, '.b');
    title(['Best Function Value: ',num2str(optimvalues.fval)]);
end
hold off; 
