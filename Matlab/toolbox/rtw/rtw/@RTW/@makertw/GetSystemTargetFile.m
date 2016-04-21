function GetSystemTargetFile(h)
%   GETSTSTEMTARGETFILE  Get the system target file
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/15 00:23:51 $
  
  [h.SystemTargetFilename,h.SystemTargetFileId] = rtwprivate('getstf', h.ModelHandle);
  
  if (h.SystemTargetFileId == -1)
    error('%s', ['make_rtw: Unable to locate system target file: ', ...
                 h.SystemTargetFilename]);
  end
  
  % Load rtw hook m-file if it exists
  h.MakeRTWHookMFile = rtwprivate('rtw_hook_name', h.SystemTargetFilename, 'make_rtw');
