function optimCleanup(this)
% Performs sunset tasks when optimization stops.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/11 00:46:31 $
try
   % Recompute current response if not all runs were optimized
   % or last logged X is not the optimal (final) X
   if isempty(this.DataLog.X)
      DataLog = getCurrentResponse(this);
   else
      DataLog = this.Datalog.Data;
   end

   % Notify related constraint editors to update their plots
   E = ctrluis.dataevent(this,'OptimStop',DataLog);
   this.send('OptimStop',E)
end
