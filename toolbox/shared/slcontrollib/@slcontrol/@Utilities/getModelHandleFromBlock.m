function hModel = getModelHandleFromBlock(this, block)
% GETMODELHANDLEFROMBLOCK Get the handle of the model containing the BLOCK.
%
% BLOCK is a Simulink block name or handle.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:10 $

h = getBlockHandle(this, block);

% Get the model handle
hModel = h;
while ~isempty(hModel.Parent)
  hModel = hModel.getParent;
end
