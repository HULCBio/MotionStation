function start(obj)
%START Start data acquisition object running.
%
%    START(OBJ) starts the hardware associated with object, OBJ, executes 
%    OBJ's StartFcn callback, then configures OBJ's Running 
%    property to 'On'.  OBJ can be either a single device object or an
%    array of device objects.
%
%    If START is called and no channels or lines are defined for the 
%    device object, OBJ, an error is returned.  
%
%    Although the device object is executing, data is not necessarily 
%    logged for analog input objects or sent for analog output objects.
%    Data logging or sending is controlled with the TriggerType property. 
%    If OBJ's TriggerType property is set to:
%
%       'Immediate' - data logging or sending occurs immediately.
%       'Manual'    - data logging or sending occurs upon calling TRIGGER.
%
%    otherwise, data logging or sending occurs when OBJ's TriggerCondition 
%    is met.
% 
%    OBJ will stop running only under one of the following conditions:
%       1. A STOP command is issued.
%       2. When the requested samples are acquired (analog input) or sent 
%          out (analog output).  For analog input, this occurs when OBJ's
%          SamplesAcquired equals the product of OBJ's SamplesPerTrigger 
%          and TriggerRepeat properties.
%       3. A runtime error occurs.
%       4. OBJ's Timeout value is reached.
%
%    The Start event is recorded in OBJ's EventLog property.
% 
%    START may be called by a data acquisition object's event callback,
%    e.g., obj.StopFcn = {'start'};
% 
%    See also DAQHELP, STOP, TRIGGER, PROPINFO.
%

%    CP 3-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:40:37 $

error('daq:start:invalidtype', 'Wrong object type passed to START. Use the object''s parent.');

