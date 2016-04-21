function compiled = isModelCompiled(this, model)
% ISMODELCOMPILED Check if the given MODEL is in compiled state.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:15 $

compiled = false;

% Get Simulink object corresponding to model
if ischar(model)
  try
    h = get_param(model, 'Object');
  catch
    error('''%s'' is not a valid Simulink model name.', model)
  end
elseif ishandle(model)
  h = handle(model);
  if ~isa(h, 'Simulink.BlockDiagram')
    error('The argument is not a valid Simulink model handle.')
  end
else
  error('A model name or handle should be provided as the argument.');
end

% Check if the Simulink object is a model
if ~strcmp(h.Type, 'block_diagram')
  error('Simulink object ''%s'' is not a valid model.', h.getFullName)
end

% Find model status
status = h.SimulationStatus;
if strcmp(status, 'paused')
  compiled = true;
end
