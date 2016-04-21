function flushdata(obj,mode)
%FLUSHDATA Remove remaining data from the data acquisition engine.
%
%    FLUSHDATA(OBJ) removes all data from the data acquisition engine for 
%    the analog input object, OBJ. OBJ can be a single analog input object 
%    or an array of analog input objects.
%
%    FLUSHDATA(OBJ,MODE) removes data from the data acquisition engine for 
%    the analog input object, OBJ. MODE can be either of the following values:
%    
%    'all'      Removes all data from the object and sets the SamplesAvailable 
%               property to 0. This is the default mode when mode is not 
%               specified, FLUSHDATA(OBJ).
%
%    'triggers' Removes the data acquired during one trigger. TriggerRepeat must
%               be greater then 0 and SamplesPerTrigger must not be set to Inf.  
%               The data associated with the oldest trigger is removed first.
%
%    See also DAQHELP, GETDATA, PROPINFO.
%

%    CP 2-1-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.14.2.5 $  $Date: 2003/12/04 18:38:26 $

if ~all(isvalid(obj))
   error('daq:flushdata:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Verify that only analog input objects are passed in.
for i = 1:length(obj)
   if ~strcmp(class(get(obj,i)), 'analoginput')
      error('daq:flushdata:invalidobject', 'Wrong object type passed to FLUSHDATA.  An analog input object is expected.');
   end
end

if nargin==1
    mode='all';
else
    if (~any(strcmp(lower(mode),{'all','triggers'})))
        error('daq:flushdata:invalidmode', 'MODE must either be (''all'',''triggers'').');
    end
end

try
   daqmex(obj,'flushdata',mode);
catch
   error('daq:flushdata:unexpected', lasterr)
end