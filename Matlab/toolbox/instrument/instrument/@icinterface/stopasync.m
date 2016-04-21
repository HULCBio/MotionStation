function stopasync(obj)
%STOPASYNC Stop asynchronous read and write.
%
%   STOPASYNC(OBJ) stops the asynchronous read and write operation that
%   is in progress with the instrument connected to interface object, 
%   OBJ. OBJ can be an instrument array.  
%
%   Data can be written asynchronously with the FPRINTF or FWRITE 
%   functions. Data can be read asynchronously with the READASYNC
%   function. For serial port, VISA-serial TCPIP and UDP objects, 
%   data can also be read asynchronously by configuring the ReadAsyncMode
%   property to continuous. In-progress asynchronous operations are
%   indicated by the TransferStatus property.
%
%   After the in-progress asynchronous operations are stopped, the 
%   TransferStatus property is configured to idle and the output buffer
%   is flushed. For serial port, VISA-serial, TCPIP and UDP objects, the
%   ReadAsyncMode property is configured to manual.
%
%   Data in the input buffer is not flushed. This data can be returned to
%   the MATLAB workspace using any of the synchronous read functions, for
%   example, FREAD or FSCANF. 
%
%   If OBJ is an array of interface objects and one of the objects cannot
%   be stopped, the remaining objects in the array will be stopped and a 
%   warning will be displayed.
%
%   Example:
%       g = gpib('ni', 0, 2);
%       fopen(g);
%       fprintf(g, 'Function:Shape Sin', 'async');
%       stopasync(g);
%       fclose(g);
%
%   See also ICINTERFACE/FSCANF, ICINTERFACE/FREAD, ICINTERFACE/FGETL,
%   ICINTERFACE/FGETS, ICINTERFACE/READASYNC, ICINTERFACE/FWRITE, 
%   ICINTERFACE/FPRINTF, INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/01/16 20:00:46 $

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

% Call stopasync on each java object.  Keep looping even 
% if one of the objects could not be stopped.  
for i=1:length(jobject)
   try
      stopasync(jobject(i));
   catch
   	  errorOccurred = true;	    
   end   
end   

% Report error if one occurred.
if errorOccurred
    if length(jobject) == 1
   	    error('instrument:stopasync:opfailed', lasterr);
    else
        warnState = warning('backtrace', 'off');
        warning('instrument:stopasync:invalid', 'An object in OBJ could not be stopped.');
        warning(warnState);
    end
end
