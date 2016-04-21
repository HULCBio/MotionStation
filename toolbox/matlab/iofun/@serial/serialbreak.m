function serialbreak(obj, time)
%SERIALBREAK Send break to device.
%
%   SERIALBREAK(OBJ) sends a break of 10 milliseconds to the device
%   connected to object, OBJ. OBJ must be a 1-by-1 serial port object.
%
%   The object, OBJ, must be connected to the device with the FOPEN
%   function before the SERIALBREAK function is issued otherwise an 
%   error will be returned. A connected object has a Status property 
%   value of open.
%
%   SERIALBREAK(OBJ, TIME) sends a break of TIME milliseconds to the
%   device connected to object, OBJ.
%
%   SERIALBREAK is a synchronous function and will block the MATLAB
%   command line until execution is completed.
%
%   An error will be returned if SERIALBREAK is called while an
%   asynchronous write is in progress. In this case, you can call the
%   STOPASYNC function to stop the asynchronous write operation or you
%   can wait for the write operation to complete.
%
%   Note that the duration of the break may be inaccurate under some
%   operating systems. 
%
%   Example:
%       s = serial('COM1');
%       fopen(s);
%       serialbreak(s);
%       serialbreak(s, 50);
%       fclose(s);
%
%   See also SERIAL/FOPEN, SERIAL/STOPASYNC.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.3 $  $Date: 2004/01/16 20:04:41 $

% Error checking.
if (length(obj) > 1)
    error('MATLAB:serial:serialbreak:invalidOBJ', 'OBJ must be a 1-by-1 serial port object.');
end

if ~isa(obj, 'serial') 
    error('MATLAB:serial:serialbreak:invalidOBJ', 'OBJ must be a serial port object.');
end

% Parse the input.
switch nargin
case 1
    time = 10;
case 2
    if ~isa(time, 'double')
        error('MATLAB:serial:serialbreak:invalidTIME', 'TIME must be a double.');
    end
end

% Call java method.
try
	serialbreak(obj.jobject, time);
catch
   error('MATLAB:serial:serialbreak:opfailed', lasterr);
end	

