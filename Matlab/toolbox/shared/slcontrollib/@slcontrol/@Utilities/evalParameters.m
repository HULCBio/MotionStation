function s = evalParameters(this, model, names)
% EVALPARAMETERS Evaluates model parameters in appropriate workspace.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:02 $

% Localize parameters in model or base workspace
WS = findParametersWS(this, model, names);
inBase = strncmp(WS, 'b', 1);
s = struct('Name', names, 'Value', [], 'Workspace', WS);

% Evaluate parameters defined in base workspace
idxB = find(inBase);
for ct = 1:length(idxB)
  idx = idxB(ct);
  try
    s(idx).Value = evalin( 'base', names{idx} );
  catch
    error( 'Parameter %s not found', names{idx} );
  end
end

% Evaluate parameters defined in model workspace
idxM = find(~inBase);
mws = get_param(model, 'ModelWorkspace' );
for ct = 1:length(idxM)
  idx = idxM(ct);
  try
    s(idx).Value = mws.evalin( names{idx} );
  catch
    error( 'Parameter %s not found', names{idx} );
  end
end
