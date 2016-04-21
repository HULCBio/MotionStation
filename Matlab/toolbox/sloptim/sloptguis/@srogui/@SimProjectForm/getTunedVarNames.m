function VarNames  = getTunedVarNames(this)
% Returns list of MATLAB variables from which tuned parameters 
% are derived.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:00 $
if isempty(this.Parameters)
   VarNames = cell(0,1);
else
   % Get current list of model parameters and references
   VarNames = strtok(get(this.Parameters,{'Name'}),'.({');
end
