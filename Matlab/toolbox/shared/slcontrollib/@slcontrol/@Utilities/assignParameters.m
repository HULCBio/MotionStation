function assignParameters(this, model, s)
% ASSIGNPARAMETERS Assigns model parameter values in appropriate workspace.
% 
% S is a structure with fields Name, Value, and Workspace.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:07:28 $

inBase = strncmp( {s.Workspace}, 'b', 1 );

% Assign parameters defined in base workspace
idxB = find(inBase);
for ct = 1:length(idxB)
  idx = idxB(ct);
  [var,subs] = strtok( s(idx).Name, '.({' );
  if isempty(subs)
    % Parameter is a variable
    assignin( 'base', var, s(idx).Value )
  else
    % Parameter is an expression
    tmp = evalin('base', var);
    rhs = s(idx).Value;
    try
      eval(['tmp' subs '= rhs;'])
    catch
      error('Expression "%s" is not a tunable parameter.', s(idx).Name)
    end
    assignin('base', var, tmp)
  end
end

% Assign parameters defined in model workspace
idxM = find(~inBase);
if ~isempty(idxM)
  mws = get_param( model, 'ModelWorkspace' );
  if ~strcmp( mws.DataSource, 'MDL-File' )
    error('Parameters cannot be modified. Model workspace source must be MDL-File.')
  end
  for ct = 1:length(idxM)
    idx = idxM(ct);
    [var,subs] = strtok( s(idx).Name, '.({' );
    if isempty(subs)
      % Parameter is a variable
      mws.assignin(var, s(idx).Value)
    else
      % Parameter is an expression
      tmp = mws.evalin('base', var);
      rhs = s(idx).Value;
      try
        eval(['tmp' subs '= rhs;'])
      catch
        error('Expression "%s" is not a tunable parameter.', s(idx).Name)
      end
      mws.assignin(var, tmp)
    end
  end
end
