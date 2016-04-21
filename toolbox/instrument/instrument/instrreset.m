function instrreset
%INSTRRESET Disconnect and delete all instrument objects.
%
%   INSTRRESET disconnects and deletes all instrument objects. If data 
%   is being written or read asynchronously, the asynchronous operation
%   is stopped.
%
%   An instrument object cannot be reconnected to the instrument after 
%   it has been deleted and should be removed from the workspace with
%   CLEAR.
%
%   See also INSTRHELP, ICINTERFACE/STOPASYNC, ICINTERFACE/FCLOSE,
%   ICINTERFACE/DELETE, ICDEVICE/DISCONNECT.
%

%   MP 07-13-99   
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.9.2.5 $  $Date: 2004/01/16 20:01:39 $

try
   % Find all objects.  Return if none were found.   
   obj = instrfind;
   if isempty(obj)
      return;
   end
   
   delete(obj);
catch
   rethrow(lasterror);     
end