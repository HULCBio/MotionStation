function trigger(obj)
%TRIGGER Send trigger message to instrument.
%
%   TRIGGER(OBJ) sends a trigger message to the instrument. OBJ must be 
%   a 1-by-1 GPIB, VISA-GPIB, VISA-VXI, VISA-USB or VISA-RSIB object. 
%
%   For GPIB, VISA-GPIB and VISA-RSIB objects, the Group Execute Trigger
%   (GET) message is sent to the instrument.  
%
%   For VISA-VXI objects, if OBJ's TriggerType property is configured to 
%   software, the Word Serial Trigger command is sent to the instrument.
%   If OBJ's TriggerType property is configured to hardware, a hardware
%   trigger is sent on the line specified by OBJ's TriggerLine property.
%
%   For VISA-USB objects, the TRIGGER message ID is sent on the Bulk-OUT 
%   pipe. If the USB instrument is not 488.2 compliant, TRIGGER will return
%   an error.
%
%   The object, OBJ, must be connected to the instrument with the FOPEN
%   function before the TRIGGER function is issued otherwise an error 
%   will be returned. A connected object has a Status property value 
%   of open.
%
%   Example:
%       g = visa('agilent', 'GPIB0::2::INSTR');
%       fopen(g);
%       trigger(g);
%
%   See also INSTRHELP, INSTRUMENT/PROPINFO.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.9.2.5 $  $Date: 2004/01/16 20:02:27 $

% Error checking.
if (length(obj) > 1)
    error('instrument:trigger:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

if any(strcmp(obj.type, {'serial', 'gpib-vxi', 'tcpip'}))
    error('instrument:trigger:invalidOBJ', 'TRIGGER is supported for GPIB, VISA-GPIB, VISA-VXI, VISA-USB and VISA-RSIB objects.');
end

% Call java method on java object.
try
    trigger(obj.jobject);
catch
    error('instrument:trigger:opfailed', lasterr);
end