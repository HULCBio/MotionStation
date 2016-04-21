function [status,errMsg] = dspblkPreApply(blockObj)
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

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:05:55 $

status = 1;
errMsg = '';

% first we validate changes
errMsg = blockObj.validateChanges;

% If they are valid, we apply them
if isempty(errMsg)
  blockObj.applyChanges;
else
  % Set status to 'failed' (to signal errors)
  status = 0;
end
