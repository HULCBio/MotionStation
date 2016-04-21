function this = fminsearch(Project)
% Creates FMINSEARCH optimizer for specified project.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:41 $
this = ResponseOptimizer.fminsearch;

% Check OPTIM is on the path
if ~license('test','Optimization_Toolbox')
   error('Simulink Response Optimization requires the Optimization Toolbox.')
end

% Initialize properties
this.initialize(Project);

% Set options
ProjOptions = Project.OptimOptions;
this.Options = optimset(optimset('fminsearch'),...
    'LargeScale','off',...
    'Display',ProjOptions.Display,...
    'MaxIter',ProjOptions.MaxIter,...
    'MaxFunEvals',Inf,...
    'TolCon',ProjOptions.TolCon,...
    'TolFun',ProjOptions.TolFun,...
    'TolX',ProjOptions.TolX);
 