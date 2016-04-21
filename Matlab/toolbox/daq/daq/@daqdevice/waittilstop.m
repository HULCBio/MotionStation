function waittilstop(obj, waittime)
%WAITTILSTOP Wait for the data acquisition object to stop running.
%
%    WAITTILSTOP(OBJ,WAITTIME) waits for the OBJ's Running property to go
%    to 'Off'. The WAITTIME specifies the maximum time in seconds to
%    wait before causing a time out error.  It is not guaranteed that the 
%    OBJ's StopFcn will be called before this function returns.
%    OBJ can be either a single device object or an array of device objects.
%    When OBJ is an array of objects then this function will wait on each 
%    object separately and therefore could wait for up to N times the WAITTIME
%    where N is the number of objects passed in.
%    If the object is not running or has an error this function will return
%    immediately.
%
%    OBJ can stop running under one of the following conditions:
%       1. When the requested samples are acquired (analog input) or sent 
%          out (analog output).
%       2. A runtime error occurs.
%       3. OBJ's Timeout value is reached.
%       4. The STOP function is issued on the object.
%
%    The Stop event is recorded in OBJ's EventLog property.
%
% 
%    See also DAQHELP, DAQDEVICE/START, DAQDEVICE/STOP, TRIGGER, PROPINFO.
%

%    PB 9-1-99
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.6.2.6 $  $Date: 2004/03/30 13:03:45 $

% Stop the object.

% Check to see if waittime is specified and error if not.
if (nargin == 1)
	error('daq:waittilstop:time', 'WAITTIME must be specified.');
end

try
   daqmex(obj,'waittilstop',waittime);
catch
   error('daq:waittilstop:unexpected', lasterr)
end

