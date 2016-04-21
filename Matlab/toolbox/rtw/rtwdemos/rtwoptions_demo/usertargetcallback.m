function usertargetcallback(hDlg, hSrc, paramName)
%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.3 $  $Date: 2004/04/15 00:26:06 $
  
  disp(['*** callback triggered:', sprintf('\n'), ...
        '  You switched popup selection to: ', ...
        slConfigUIGetVal(hDlg, hSrc, paramName)]);
  

