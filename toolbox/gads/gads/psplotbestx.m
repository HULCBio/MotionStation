function stop = psplotbestx(optimvalues,flag)
%PSPLOTBESTF: PlotFcn to plot best X value.
%   STOP = PSPLOTBESTX(OTIMVALUES,FLAG) where OPTIMVALUES is a structure
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
%   $Revision: 1.6.4.1 $  $Date: 2004/04/06 01:09:59 $

stop = false;
if(strcmp(flag,'init'))
  title('Current Best Point')
  xlabel(['Number of variables (',num2str(length(optimvalues.x)),')']);
  ylabel('Current best point');
end

Xlength = length(optimvalues.x);
h = bar(double(optimvalues.x(:)));
set(h,'edgec','none')
set(gca,'xlim',[0,1 + Xlength])
