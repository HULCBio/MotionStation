function initpar(this)
% Initializes tuned parameters to their current value 
% in model or base workspace.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:13 $
%   Copyright 1986-2003 The MathWorks, Inc.
pv = utEvalParams(this.Model,get(this.Parameters,{'Name'}));
for ct=1:length(this.Parameters)
   this.Parameters(ct).InitialGuess = pv(ct).Value;
end
