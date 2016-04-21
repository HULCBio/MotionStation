function configDlgCallback(hObj, hDlg, tag, action)
% Internal Helper function

% Copyright 2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  if isa(hObj, 'Simulink.ConfigSetDialogController')
    hObj.dialogCallback(hDlg, tag, action);
    hDlg.enableApplyButton(1);
  else
    error('Internal error: cannot execute dialog callback');
  end
  