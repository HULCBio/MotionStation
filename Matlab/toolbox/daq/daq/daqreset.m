function daqreset
%DAQRESET Delete and unload all data acquisition objects and DLLs.
%
%    DAQRESET deletes any data acquisition objects existing in the
%    engine as well as unloads all DLLs loaded by the engine.  The
%    adaptor DLLs and daqmex.dll are also unlocked and unloaded.  As
%    a result, the data acquisition hardware is reset.
%
%    DAQRESET is the data acquisition command that returns MATLAB to 
%    the known state of having no data acquisition objects and no 
%    loaded data acquisition DLLs.
%
%    See also DAQHELP, DAQDEVICE/DELETE, DAQ/PRIVATE/CLEAR.
%

%    MP 01-05-99   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.4 $  $Date: 2003/08/29 04:40:54 $

try
   % Find the objects in the engine.  Return if none were found.   
   daqobj = daqfind;
   if isempty(daqobj)
      return;
   end
   
   % Get the handles and pass to daqmex to stop and delete.
   handles = daqgetfield(daqobj, 'handle');
   for i=1:length(handles),
      daqmex(handles(i),'stop');
      daqmex(handles(i),'delete');
   end
   
   clear daqmex
   
catch
   error('daq:daqreset:unexpected', lasterr)
end
