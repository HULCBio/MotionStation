function dspblkDDClose
% dspblkDDClose
%   Close the Dynamic Dialog interface for the current block, if it exists
%

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/08/25 05:38:14 $

blk = gcb;
toolRoot = DAStudio.ToolRoot;
dlgs = toolRoot.getOpenDialogs;
% loop over close dialogs to see if one already exists
% use getDialogTag - tag is block's name (gcb)
hDialog = [];
for ind = 1:length(dlgs)
  if strcmp(dlgs(ind).DialogTag,blk)
    hDialog = dlgs(ind);
    break;
  end
end

if ~isempty(hDialog)
  % close the dialog
  delete(hDialog);
end

% {EOF]
