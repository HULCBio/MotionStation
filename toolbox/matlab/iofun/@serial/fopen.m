function fopen(obj)
%FOPEN Connect serial port object to device.
%
%   FOPEN(OBJ) connects the serial port object, OBJ, to the device. OBJ
%   can be an array of serial port objects.
%
%   Only one serial port object with the same configuration can be connected
%   to an instrument at a time. For example, only one serial port object
%   can be connected to the COM2 port at a time. If OBJ was successfully
%   connected to the device, OBJ's Status property is configured to open,
%   otherwise the Status property remains configured to closed.
%
%   When OBJ is opened, any data remaining in the input buffer and the 
%   output buffer is flushed and the BytesAvailable, BytesToOutput,
%   ValuesReceived and ValuesSent properties are reset to 0. 
%
%   Some property values can only be verified after the connection to 
%   the device has been made. Examples include BaudRate, FlowControl, 
%   and Parity. If any of these properties are set to a value not 
%   supported by the device, an error will be returned and the object  
%   will not be connected to the device.
%
%   Some properties are read-only while the serial port object is open
%   (connected) and must be configured before using FOPEN. Examples
%   include InputBufferSize and OutputBufferSize. 
%
%   An error will be returned if FOPEN is called on a serial port object
%   that has a Status property value of Open.
%
%   The byte order of the device can be specified with OBJ's ByteOrder
%   property.
%
%   If OBJ is an array of serial port objects and one of the objects
%   cannot be connected to the device, the remaining objects in the
%   array will be connected to the device and a warning will be displayed.
%
%   Example:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%
%   See also SERIAL/FCLOSE.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $  $Date: 2004/01/16 20:04:14 $

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

warnState = warning('backtrace', 'off');

% Call fopen on each java object.  Keep looping even 
% if one of the objects could not be opened.  
for i=1:length(jobject),
   try
      fopen(jobject(i));
   catch
   	  errorOccurred = true;	    
   end   
end   

% Report error if one occurred.
if errorOccurred
    if length(jobject) == 1
        warning(warnState);
        error('MATLAB:serial:fopen:opfailed', lasterr);
    else
        warning('MATLAB:serial:fopen:invalid','An object in OBJ could not be opened or was already open.');
    end
end

warning(warnState);

