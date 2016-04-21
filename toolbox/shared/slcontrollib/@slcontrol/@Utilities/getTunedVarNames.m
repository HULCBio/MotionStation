function VarNames = getTunedVarNames(this, hParams)
% GETTUNEDVARNAMES Returns list of MATLAB variables from which tuned parameters 
% are derived.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:14 $

if isempty(hParams)
  VarNames = cell(0,1);
else
  % Get current list of model parameters
  VarNames = strtok( get(hParams, {'Name'}), '.({' );
end
