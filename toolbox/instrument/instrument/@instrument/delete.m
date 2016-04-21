function delete(obj)
%DELETE Remove instrument object from memory.
%
%   DELETE(OBJ) removes instrument object, OBJ, from memory. When OBJ is 
%   deleted, it becomes an invalid object and cannot be reconnected to
%   the instrument. An invalid object should be removed from the workspace
%   with the CLEAR command.
%
%   If multiple references to an instrument object exist in the workspace,
%   then deleting one instrument object invalidates the remaining references.
%   These remaining references should be cleared from the workspace with
%   the CLEAR command.
%
%   If the instrument object is connected to the instrument, i.e. has a 
%   Status property value of open, the instrument object will be disconnected
%   from the instrument and then deleted.
%
%   If OBJ is an interface object being used by a device object then the device
%   object will also be deleted when OBJ is deleted. If OBJ is a device object, 
%   the interface object being used by the device object will not be deleted 
%   when OBJ is deleted.
%
%   If OBJ is an array of instrument objects and one of the objects cannot
%   be deleted, the remaining objects in the array will be deleted and a 
%   warning will be returned.
%
%   DELETE should be used at the end of an instrument session.
%
%   Example:
%       g = gpib('ni', 0, 1);
%       fopen(g);
%       fprintf(g, '*IDN?');
%       idn = fscanf(g);
%       fclose(g);
%       delete(g);
%
%   See also ICINTERFACE/FCLOSE, ICDEVICE/DISCONNECT, INSTRUMENT/ISVALID, 
%   INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.11.2.5 $  $Date: 2004/01/16 20:00:50 $

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

% Call dispose on each java object.  Keep looping even 
% if one of the objects could not be deleted.  
for i=1:length(jobject)
   if (isvalid(jobject(i))) 
       try
           if isa(java(jobject(i)), 'com.mathworks.toolbox.instrument.Instrument')
               % Disconnect the objects from the hardware.
               stopasync(jobject(i)); 
               fclose(jobject(i));
           end 
           
           % Delete.
           dispose(jobject(i));
           disconnect(jobject(i));
           cleanup(jobject(i));
       catch
           errorOccurred = true;	    
       end
   end
end   

% Report error if one occurred.
if errorOccurred
    if length(jobject) == 1
        error('instrument:delete:opfailed', lasterr);
    else
        warnState = warning('backtrace', 'off');
        warning('instrument:delete:invalid', 'An object in OBJ could not be deleted.');
        warning(warnState);
    end
end
