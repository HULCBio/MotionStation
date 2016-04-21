function s = utEvalParams(Model,pnames)
% Evaluates model parameters in appropriate workspace.

%   $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:41:32 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Localize parameters in model or base workspace
WS = utFindParams(Model,pnames);
inBase = strncmp(WS,'b',1);
s = struct('Name',pnames,'Value',[],'Workspace',WS);

% Evaluate parameters defined in model workspace
idxM = find(~inBase);
if ~isempty(idxM)
   mws = get_param(Model,'ModelWorkspace');
   for ct=1:length(idxM)
      idx = idxM(ct);
      s(idx).Value = mws.evalin(pnames{idx});
   end
end

% Evaluate parameters defined in base workspace
idxB = find(inBase);
for ct=1:length(idxB)
   idx = idxB(ct);
   try
      s(idx).Value = evalin('base',pnames{idx});
   catch
      error('Could not evaluate parameter %s.',pnames{idx});
   end
end
