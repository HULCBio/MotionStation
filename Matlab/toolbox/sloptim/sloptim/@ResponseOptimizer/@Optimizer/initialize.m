function initialize(this,Project)
% Initializes @Optimizer object

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/01/03 12:28:22 $
if ~isa(Project, 'ResponseOptimizer.Project')
  error('Incorrect input argument.')
end

% Initialize properties
this.Project = Project;

% Create gradient model object.
OptimOptions = Project.OptimOptions;
if strcmp( OptimOptions.GradientType, 'refined' ) &&...
      any(strcmp(OptimOptions.Algorithm,{'fmincon'}))
   % Create gradient model
   this.Gradient = makeGradient(Project);
end
