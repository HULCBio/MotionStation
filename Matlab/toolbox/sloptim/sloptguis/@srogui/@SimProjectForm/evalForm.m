function Proj = evalForm(this)
% Evaluates literal project settings in appropriate workspace
% to produce runnable, numeric project description.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:57 $
%   Copyright 1986-2003 The MathWorks, Inc.
Proj = ResponseOptimizer.SimProject;
Proj.Name = this.Name;
Proj.Model = this.Model;

% Get list of variable names in model workspace
ModelWS = get_param(this.Model,'ModelWorkspace');
s = whos(ModelWS);
ModelWSVars = {s.name};

% Evaluate parameter specs
Params = [];
for ct=1:length(this.Parameters)
   Params = [Params ; ...
      evalForm(this.Parameters(ct),ModelWS,ModelWSVars)];
end
Proj.Parameters = Params;

% Evaluate test specs
Tests = [];
for ct=1:length(this.Tests)
   Tests = [Tests ; evalForm(this.Tests(ct),ModelWS,ModelWSVars)];
end
Proj.Tests = Tests;

% Optimization settings
Proj.OptimOptions = evalForm(this.OptimOptions,ModelWS,ModelWSVars);
