function evalin(this,Params)
% Evaluates parameter values in appropriate workspace.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:10 $
%   Copyright 1986-2003 The MathWorks, Inc.
pv = utEvalParams(this.Model,get(Params,{'Name'}));
for ct=1:length(Params)
   Params(ct).Value = pv(ct).Value;
end
