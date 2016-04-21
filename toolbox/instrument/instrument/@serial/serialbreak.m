function serialbreak(obj, time)
%SERIALBREAK Send break to instrument.
%
%   SERIALBREAK(OBJ) sends a break of 10 milliseconds to the instrument
%   connected to object, OBJ. OBJ must be a 1-by-1 serial port object.
%
%   The object, OBJ, must be connected to the instrument with the FOPEN
%   function before the SERIALBREAK function is issued otherwise an error 
%   will be returned. A connected object has a Status property value 
%   of open.
%
%   SERIALBREAK(OBJ, TIME) sends a break of TIME milliseconds to the
%   instrument connected to object, OBJ.
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
%   See also ICINTERFACE/FOPEN, ICINTERFACE/STOPASYNC, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.8.2.4 $  $Date: 2004/01/16 20:01:29 $

% Error checking.
if (length(obj) > 1)
    error('instrument:serialbreak:invalidOBJ', 'OBJ must be a 1-by-1 serial port object.');
end

if ~isa(obj, 'serial') 
    error('instrument:serialbreak:invalidOBJ', 'OBJ must be a serial port object.');
end

% Parse the input.
switch nargin
case 1
    time = 10;
case 2
    if ~isa(time, 'double')
        error('instrument:serialbreak:invalidTIME', 'TIME must be a double.');
    end
end

% Call java method.
try
	serialbreak(obj.jobject, time);
catch
    error('instrument:serialbreak:opfailed', lasterr);
end	

