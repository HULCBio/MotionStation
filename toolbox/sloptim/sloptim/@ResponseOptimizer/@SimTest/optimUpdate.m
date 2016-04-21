function optimUpdate(this)
% Performs update tasks as optimization progresses.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:33 $
try
   % Recompute current response if not all runs were optimized
   % or last logged X is not the current best X
   if isempty(this.DataLog.X)
      DataLog = getCurrentResponse(this);
   else
      DataLog = this.Datalog.Data;
   end

   % Notify related constraint editors to update their plots
   E = ctrluis.dataevent(this,'OptimUpdate',DataLog);
   this.send('OptimUpdate',E)
end
