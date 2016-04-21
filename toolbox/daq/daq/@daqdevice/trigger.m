function trigger(obj, event)
%TRIGGER Manually initiate logging/sending for running object.
%
%    TRIGGER(OBJ) executes OBJ's TriggerFcn callback, records the absolute
%    time of the trigger event in OBJ's InitialTriggerTime property, then 
%    configures OBJ's Logging or Sending property to 'On'.  OBJ can be either 
%    a single device object or an array of device objects.
%
%    TRIGGER can only be invoked if OBJ is running and its TriggerType
%    property is set to 'Manual'.
%
%    The Trigger event is recorded in OBJ's EventLog property.
%
%    TRIGGER may be called by a data acquisition object's event callback e.g.,
%    obj.StartFcn = @trigger;
%
%    See also DAQHELP, DAQDEVICE/START, STOP, PROPINFO.
%

%    MP 4-10-98   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:41:32 $

if nargout>0,
   error('daq:trigger:argcheck', 'Too many output arguments.')
end

% If two inputs are given, verify that the second input is the event
% structure otherwise error.
if nargin == 2
   if ~(isfield(event, 'Type') && isfield(event, 'Data'))
      error('daq:trigger:argcheck', 'Too many input arguments.');
   end
end

% Error if a digitalio object is passed.
if isa(obj, 'digitalio')
   error('daq:trigger:invalidobject', 'OBJ must be an analog input or analog output object.');
end

% Determine if an invalid handle was passed.
if ~isvalid(obj)
   error('daq:trigger:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

if strcmp(get(obj,'Running'),'Off'),
   error('daq:trigger:notrunning', 'Device must be started before executing a manual trigger.  Call START.')
end

if ~strcmp(get(obj,'TriggerType'),'Manual'),
   error('daq:trigger:badtriggertype', 'TRIGGER(OBJ) ignored since OBJ''s TriggerType is not set to ''Manual''.')
end

try
   daqmex(obj,'trigger')
catch
   error('daq:trigger:unexpected', lasterr)
end
