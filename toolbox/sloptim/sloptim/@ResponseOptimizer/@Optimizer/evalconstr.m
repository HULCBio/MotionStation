function C = evalconstr(this,x,j)
% Evaluates constraints at x

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:26 $
Proj = this.Project;
Tests = find(Proj.Tests,'Enable','on','Optimized','on');

% X -> parameter values
this.var2par(x)

% Update parameter values in model workspace
Proj.assignin(Proj.Parameters);

% Evaluate constraints
C = [];
for ct=1:length(Tests)
   C = [C ; evalFC(Tests(ct),'Constraint',x,j,this.Info)];
end
