function fopen(obj)
%FOPEN Connect interface object to instrument.
%
%   FOPEN(OBJ) connects the interface object, OBJ, to the instrument.
%   OBJ can be an instrument array.
%
%   Only one interface object with the same configuration can be connected
%   to an instrument at a time. For example, only one serial port object
%   can be connected to the COM2 port at a time. Similarly, only one GPIB
%   object can be connected to an instrument with a given BoardIndex, 
%   PrimaryAddress and SecondaryAddress. If OBJ was successfully connected
%   to the instrument, OBJ's Status property is configured to open,
%   otherwise the Status property remains configured to closed.
%
%   When OBJ is opened, any data remaining in the input buffer and the 
%   output buffer is flushed and the BytesAvailable, BytesToOutput,
%   ValuesReceived and ValuesSent properties are reset to 0. 
%
%   For a TCPIP object, FOPEN establishes the connection with the remote host.
%   For a UDP object, FOPEN binds the OBJ to the local socket.
%
%   For GPIB, VISA-GPIB, VISA-VXI, VISA-GPIB-VXI and VISA-USB objects, the
%   buffer of the instrument can be cleared with the CLRDEVICE function.
%
%   Some property values can only be verified after the connection to the
%   instrument has been made. Examples include BaudRate, SecondaryAddress
%   and Parity. If any of these properties are set to a value not supported
%   by the instrument, an error will be returned and the object will not be
%   connected to the instrument.
%
%   Some properties are read-only while the interface object is open
%   (connected) and must be configured before using FOPEN. Examples
%   include InputBufferSize and OutputBufferSize. PROPINFO can be
%   used to determine when a property can be set.
%
%   An error will be returned if FOPEN is called on an interface object 
%   that has a Status property value of open.
%
%   The byte order of the instrument can be specified with OBJ's
%   ByteOrder property.
%
%   If OBJ is an array of interface objects and one of the objects
%   cannot be connected to the instrument, the remaining objects in 
%   the array will be connected to the instrument and a warning will
%   be displayed.
%
%   Example:
%       g = gpib('ni', 0, 2);
%       fopen(g)
%       fprintf(g, '*IDN?');
%       idn = fscanf(g);
%       fclose(g);
%
%   See also ICINTERFACE/FCLOSE, CLRDEVICE, INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/01/16 20:00:32 $

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

% fopen on udp may throw a warning.
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
        error('instrument:fopen:opfailed', lasterr);
    else
        warning('instrument:fopen:invalid', 'An object in OBJ could not be opened or was already open.');
    end
end

warning(warnState);


