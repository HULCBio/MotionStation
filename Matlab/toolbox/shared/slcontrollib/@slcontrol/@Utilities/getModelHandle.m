function h = getModelHandle(this, model)
% GETMODELHANDLE Get the handle of the MODEL
%
% MODEL is a Simulink model name or handle.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:09 $

% Get Simulink object corresponding to model
if ischar(model)
  try
    h = get_param(model, 'Object');
  catch
    error('Unable to find the model named ''%s''.', model)
  end
elseif ishandle(model)
  h = handle(model);
  if ~isa(h, 'Simulink.BlockDiagram')
    error('The object ''%s'' is not a valid Simulink model.', class(h))
  end
else
  error('A valid block name or handle should be provided.');
end

% Check if the Simulink object is a block
if ~strcmp(h.Type, 'block_diagram')
  error('Simulink object ''%s'' is not a valid model.', h.getFullName)
end
