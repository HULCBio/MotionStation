function [status,errMsg] = dspblkDDGPreApplyWithFracLengthUpdate(blockObj,dlg,tags,text)
% dspblkPreApplyWithFracLengthUpdate(blockObj)
%   validates changes made in a block's Dynamic Dialog
%   and then appplies the changes if valid.  Checks some
%   tagged widgets for a particular sentinel string value
%   and replaces with '0' for the write-to-block phase.
%   DataTypeRowBestPrec/Fractional need this because the
%   'best precision' string must not be written to the 
%   underlying block - MATLAB will error.
%  
%   blockObj = top-level UDD object for the block (the one
%              that getDialogSchema() is called on)
%   dlg      = DDG dialog handle
%   tags     = tags of widgets taht need to be checked
%   text     = text string to check for
%  
%   returns the status (0 = failed) and error message if failed
%

% Copyright 2003 The MathWorks, Inc.

status = 1;
errMsg = '';

% update frac lengths
changed = [];
for ind = 1:length(tags)
  if strcmp(dlg.getWidgetValue(tags{ind}),text)
    dlg.setWidgetValue(tags{ind},'0');
    changed = [changed ind];
  end
end

% call standard preApply
[status,errMsg] = dspDDGPreApply(blockObj,dlg);

% change 'em back
for ind = 1:length(changed)
    dlg.setWidgetValue(tags{changed(ind)},text);
end
