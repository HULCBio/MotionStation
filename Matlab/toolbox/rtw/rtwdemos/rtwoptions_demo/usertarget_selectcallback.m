function usertarget_selectcallback(hDlg, hSrc)
%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/12 23:50:03 $
  
  disp(['*** Select callback triggered:', sprintf('\n'), ...
        '  Uncheck and disable "Terminate function required".']);
  slConfigUISetVal(hDlg, hSrc, 'IncludeMdlTerminateFcn', 'off');
  slConfigUISetEnabled(hDlg, hSrc, 'IncludeMdlTerminateFcn', false);
