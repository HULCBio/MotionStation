function this = patternsearch(Project)
% Creates PATTERNSEARCH optimizer for specified project.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:46 $
this = ResponseOptimizer.patternsearch;

% Check ithat GADS is on the path
if ~license('test','GADS_Toolbox')
   error('The Pattern Search option requires the Genetic Algorithm Direct Search Toolbox.')
end

% Initialize properties
this.initialize(Project);

% Default options
ProjOptions = Project.OptimOptions;
this.Options = psoptimset(psoptimset,...
    'Display',ProjOptions.Display,...
    'MaxIteration',ProjOptions.MaxIter,...
    'MaxFunEvals',Inf,...
    'TolFun',ProjOptions.TolFun,...
    'TolX',ProjOptions.TolX,...
    'TolMesh',ProjOptions.TolX,...
    'CompleteSearch','on',...
    'SearchMethod',ProjOptions.SearchMethod);
this.Options.TolCon = ProjOptions.TolCon;
