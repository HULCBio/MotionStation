function s = getWorkspaceVarsAsStruct(blk)
% Get mask workspace variables:

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2002/11/14 02:47:07 $

ss = get_param(blk,'maskwsvariables');
if isempty(ss),
    s=struct([]);
    warning('getWorkspaceVarsAsStruct: no ws vars');
    return
end

% Only the first "numdlg" variables are from dialog;
% others are created in the mask init fcn itself.
dlg = get_param(blk,'masknames');
numdlg = length(dlg);
ss = ss(1:numdlg);

% Create a structure with:
%   field names  = variable names
%   field values = variable values
s = cell2struct({ss.Value}',{ss.Name}',1);

% [EOF] $File: $
