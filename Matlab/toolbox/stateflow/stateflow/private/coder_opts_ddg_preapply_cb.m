function [res, err] = coder_opts_ddg_preapply_cb(dlgH, numWidgets)

% Copyright 2002-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:56:21 $

if ~ishandle(dlgH)
    return;
end

targetId = dlgH.getDialogSource.Id;

% Get the flag info from the target, and the uicontrols from the gui
flags   = target_methods('codeflags',targetId);

for i = 1:length(flags)
    val = dlgH.getWidgetValue(int2str(i));
    flags(i).value = val;
end

% Update the data dictionary if any flags have changed
target_methods('setcodeflags',targetId,flags);

err = [];
res = 1;