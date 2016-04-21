function [status,errMsg] = dspblkDDGPreApply(blockObj,dlg)
% dspblkPreApply(blockObj)
%   validates changes made in a block's Dynamic Dialog
%   and then appplies the changes if valid
%  
%   blockObj = top-level UDD object for the block (the one
%              that getDialogSchema() is called on)
%  
%   returns the status (0 = failed) and error message if failed
%
%  This function is intended to to be used in the getDialogSchema
%  function:
%
%  function dlgstruct = getDialogSchema(h, name)
%    % construct schema
%    dlgstruct.PreApplyCallback = 'dspblkPreApply';
%    dlgstruct.PreApplyArgs = {h};

% Copyright 2003-2004 The MathWorks, Inc.

status = 1;
errMsg = '';

% first we validate changes
errMsg = blockObj.validateChanges;

% If they are valid, we apply them
%if isempty(errMsg)
%  blockObj.applyChanges;
%end
%
%% return any errors
if ~isempty(errMsg)
  status = 0;
else
  [status,errMsg] = blockObj.preApplyCallback(dlg);
  % Talk about your paranoia checks...  preApplyCallback is a C++ function that
  % returns [status,errMsg] in the C++ world.  For about 3-4 months (late '03),
  % in the M world, it was returning these args in the order [errMsg, status].
  % This appears to be fixed, but let's check to make sure
  
  if ischar(status)
    warning('SLDialogController::preApplyCallback''s return args have switched order!');
    tmp = status;
    status = errMsg;
    errMsg = tmp;
  end
end
