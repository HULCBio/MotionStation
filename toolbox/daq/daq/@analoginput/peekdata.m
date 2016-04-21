function data=peekdata(obj,samples)
%PEEKDATA Preview most recent acquired data.
%
%    PEEKDATA(OBJ,SAMPLES)
%    DATA = PEEKDATA(OBJ,SAMPLES) returns the latest number of samples 
%    specified by SAMPLES to DATA.  If SAMPLES is greater than the number of
%    samples currently acquired, all available samples will be returned 
%    with a warning message stating that the requested number of samples 
%    were not available.  OBJ must be a 1-by-1 analog input object.
%
%    PEEKDATA is an non-blocking function that immediately returns data
%    samples and execution control to the MATLAB workspace.  Not all
%    requested data may be returned.
%
%    OBJ's SamplesAvailable property value will not be affected by the
%    number of samples returned by PEEKDATA.  This means that PEEKDATA
%    only looks at the data, it does not remove the data from the data 
%    acquisition engine.
%
%    PEEKDATA can be used only after the START command is issued and while
%    OBJ is running. PEEKDATA may also be called once after OBJ has stopped
%    running.
%
%    See also DAQHELP, GETDATA, GETSAMPLE, PROPINFO, DAQDEVICE/START.
%

%    CP 3-02-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:39:39 $

ArgChkMsg = nargchk(2,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:peekdata:argcheck', ArgChkMsg);
end

% PEEKDATA does not accept device arrays.
if length(obj) > 1
   error('daq:peekdata:invalidobject', 'OBJ must be a 1-by-1 analog input object.');
end

% Check for an analog input object.
if ~isa(obj, 'analoginput') 
   error('daq:peekdata:invalidobject', 'OBJ must be a 1-by-1 analog input object.');
end

% Determine if the object is valid.
if ~all(isvalid(obj))
   error('daq:peekdata:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Error if second input is not an integer scalar.
if ~strcmp(class(samples), 'double') || all(floor(samples) ~= samples) || length(samples) ~= 1
   error('daq:peekdata:invalidsamples', 'SAMPLES must be a scalar value.');
end

% Get the requested samples.
try
   data=daqmex(obj,'peekdata',samples);
catch
   error('daq:peekdata:unexpected', lasterr)
end