function dspblkDDOpen(blockClass)
% dspblkDDOpen(blockType)
%   Open the Dynamic Dialog interface for a block (creating an
%   interface if one does not already exist).
%
%   blockClass = UDD class for the block.  The class is assumed
%                to be in the dspdialog package.
%
% Example:
%   dspblkDDOpen('FFT') opens a Dynamic Dialog interface for
%   an FFT block

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/08/25 05:38:15 $

blk = gcb;
toolRoot = DAStudio.ToolRoot;
dlgs = toolRoot.getOpenDialogs;
% loop over open dialogs to see if one already exists
% use getDialogTag - tag is block's name (gcb)
hDialog = [];
for ind = 1:length(dlgs)
  if strcmp(dlgs(ind).DialogTag,blk)
    hDialog = dlgs(ind);
    break;
  end
end

if isempty(hDialog)
  block = dspdialog.(blockClass)(gcbh);
  hDialog = DAStudio.Dialog(block,gcb,'DLG_STANDALONE');
  hDialog.resetSize;
else
  % de-minimize it
  hDialog.showNormal;
  % bring it to the front
  hDialog.show;
  % make sure it's sized well
  hDialog.resetSize;
end

