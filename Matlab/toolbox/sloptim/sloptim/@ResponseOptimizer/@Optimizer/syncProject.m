function syncProject(this,x)
% Syncs parameter data with current best x and clears
% last data log if for a different x.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:36 $
Proj = this.Project;

% Propagate best x to parameters and model
this.var2par(x)
Proj.assignin(Proj.Parameters);

% Look for out-of-sync data logs
% RE: When using search algorithms, best x is typically not the last value tried
for ct=1:length(Proj.Tests)
   t = Proj.Tests(ct);
   if isempty(t.DataLog.Data)
      t.DataLog.X = [];
   else
      % Check if last log is for the best current x
      xlog = t.DataLog.X;
      isEmptyLog = cellfun('isempty',t.DataLog.Data);
      if any(isEmptyLog(:)) || ~isequal(x(1:length(xlog)),xlog)
         % Clear cached values to force reevaluation at x
         t.DataLog.X = [];
      end
   end
end
