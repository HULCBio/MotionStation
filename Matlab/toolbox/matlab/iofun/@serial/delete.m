function delete(obj)
%DELETE Remove serial port object from memory.
%
%   DELETE(OBJ) removes serial port object, OBJ, from memory. When OBJ
%   is deleted, it becomes an invalid object and cannot be reconnected 
%   to the device and should be removed from the workspace with CLEAR.
%
%   If multiple references to a serial port object exist in the workspace,
%   then deleting one serial port object invalidates the remaining 
%   references. These remaining references should be cleared from the
%   workspace with the CLEAR command.
%
%   If the serial port object is connected to a device, i.e. has a Status
%   property value of open, the serial port object will be disconnected
%   from the device with the FCLOSE function and then deleted.
%
%   If OBJ is an array of serial port objects and one of the objects
%   cannot be deleted, the remaining objects in the array will be deleted 
%   and a warning will be displayed.
%
%   DELETE should be used at the end of a serial port session.
%
%   See also SERIAL/FCLOSE, SERIAL/ISVALID.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $  $Date: 2004/01/16 20:04:05 $

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
   		error('MATLAB:serial:delete:opfailed', lasterr);
    else
        warnState = warning('backtrace', 'off');
        warning('MATLAB:serial:delete:invalid', 'An object in OBJ could not be deleted.');
        warning(warnState);
    end
end
