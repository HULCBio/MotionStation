function h = getBlockHandle(this, block)
% GETBLOCKHANDLE Get the handle of the BLOCK
%
% BLOCK is a Simulink block name or handle.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:07 $

% Get Simulink object corresponding to block
if ischar(block)
  try
    h = get_param(block, 'Object');
  catch
    error('''%s'' is not a valid Simulink block name.', block)
  end
elseif ishandle(block)
  h = handle(block);
  if ~isa(h, 'Simulink.Block')
    error('The object ''%s'' is not a valid Simulink block.', class(h))
  end
else
  error('A valid block name or handle should be provided.');
end

% Check if the Simulink object is a block
if ~strcmp(h.Type, 'block')
  error('Simulink object ''%s'' is not a valid block.', h.getFullName)
end
