function Gs = slackgrad(this,x)
% Computes constraint gradient wrt slack variable (last entry of x).
% Simulation-free.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:35 $
Proj = this.Project;
Tests = find(Proj.Tests,'Enable','on','Optimized','on');

% X -> parameter values
this.var2par(x)

% Update parameter values in model workspace
Proj.assignin(Proj.Parameters);

% Perturbations
xx = x(1:end-1);  % parameters
gamma = x(end);
dg = 0.01*(1+abs(gamma));

% Evaluate constraints
Gs = [];
for ct=1:length(Tests)
   t = Tests(ct);
   dC = t.evalFC('Constraint',[xx;gamma+dg],0,this.Info) - ...
      t.evalFC('Constraint',[xx;gamma-dg],0,this.Info);
   Gs = [Gs ; dC/(2*dg)];
end
Gs = Gs.';
