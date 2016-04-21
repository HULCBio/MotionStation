function trigger(obj)
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


%    PB 01-01-01  
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.4 $  $Date: 2003/08/29 04:40:39 $

ArgChkMsg = nargchk(1,1,nargin);
if ~isempty(ArgChkMsg)
    error('daq:trigger:argcheck', ArgChkMsg);
end

if nargout>0,
   error('daq:trigger:argcheck', 'Too many output arguments.')
end

error('daq:trigger:invalidtype', 'Wrong object type passed to TRIGGER. Use the object''s parent.');