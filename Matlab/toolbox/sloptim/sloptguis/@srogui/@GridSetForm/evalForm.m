function uset = evalForm(this,varargin)
% Evaluates literal uncertainty specification in appropriate workspace.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.1 $ $Date: 2004/01/03 12:27:09 $
%   Copyright 1986-2004 The MathWorks, Inc.
np = length(this.Parameters);
Args = cell(2,np);
for ct=1:np
   Args{1,ct} = this.Parameters(ct).Name;
   try
      Args{2,ct} = utEvalModelVar(this.Parameters(ct).Values,varargin{:});
   catch
      error('Cannot evaluate value set for uncertain parameter %s.',Args{1,ct})
   end
end
uset = gridunc(Args{:});
uset.setOptimized(this.Optimized);
