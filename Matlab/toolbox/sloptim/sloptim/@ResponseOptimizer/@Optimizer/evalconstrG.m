function dC = evalconstrG(this,x,j,xL,xR)
% Evaluates constraints at x

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:27 $
Proj = this.Project;
Tests = find(Proj.Tests,'Enable','on','Optimized','on');
GradModel = this.Gradient.GradModel;

% Set L/R parameter values in gradient model
var2parG(this,xL,xR)

% Evaluate constraints
dC = [];
for ct=1:length(Tests)
   dC = [dC ; evalFCG(Tests(ct),'Constraint',...
      GradModel,x,j,xL,xR,this.Info)];
end
