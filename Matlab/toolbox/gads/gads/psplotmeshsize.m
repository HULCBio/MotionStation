function stop = psplotmeshsize(optimvalues,flag)
%PSPLOTMESHSIZE: PlotFcn to plot mesh size.
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
%   $Revision: 1.11.4.1 $  $Date: 2004/04/06 01:10:01 $

stop = false;
hold on;
if(strcmp(flag,'init'))
    grid on;
    plot(optimvalues.iteration,optimvalues.meshsize, '.m');
    xlabel('Iteration'); ylabel('Mesh size');
end

if strcmpi(flag, 'iter')
    plot(optimvalues.iteration,optimvalues.meshsize, '.m');
    title(['Current Mesh Size: ',num2str(optimvalues.meshsize)])
end
hold off;
