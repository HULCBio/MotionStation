function uset = evalForm(this,varargin)
% Evaluates literal uncertainty specification in appropriate workspace.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.1 $ $Date: 2004/01/03 12:27:20 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Evaluate spec
np = length(this.Parameters);
Args = cell(2,np);
for ct=1:np
   Args{1,ct} = this.Parameters(ct).Name;
   try
      Args{2,ct} = {...
         utEvalModelVar(this.Parameters(ct).Min,varargin{:});...
         utEvalModelVar(this.Parameters(ct).Max,varargin{:})};
   catch
      error('Cannot evaluate value set for uncertain parameter %s.',Args{1,ct})
   end
end
try
   nSamples = utEvalModelVar(this.NumSamples,varargin{:});
catch
   error('Cannot evaluate number of parameter samples.')
end
uset = randunc(nSamples,Args{:});
uset.setOptimized(this.Optimized);
