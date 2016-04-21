function clrdevice(obj)
%CLRDEVICE Clear instrument buffer.
%
%   CLRDEVICE(OBJ) clears the buffer of the instrument connected to
%   interface object, OBJ. OBJ must be a 1-by-1 GPIB, VISA-GPIB, 
%   VISA-VXI, VISA-USB or VISA-RSIB object.
%
%   For GPIB or VISA-GPIB objects, the GPIB Selected Device Clear (SDC)
%   message is sent to the instrument. 
%
%   For VISA-VXI objects, the Word Serial Clear message is sent to the 
%   instrument. 
%
%   For VISA-USB objects, the INITIATE_CLEAR and CHECK_CLEAR_STATUS commands
%   are sent to the instrument on the control pipe.
%
%   The object, OBJ, must be connected to the instrument with the 
%   FOPEN function before the CLRDEVICE function is issued otherwise 
%   an error will be returned. A connected object has a Status 
%   property value of open.
%
%   You can clear the software input buffer using the FLUSHINPUT 
%   function. You can clear the software output buffer using the 
%   FLUSHOUTPUT function.
%
%   Example:
%       g = visa('agilent', 'GPIB0::2::INSTR');
%       fopen(g);
%       fprintf(g, '*IDN?');
%       clrdevice(g);
%
%   See also ICINTERFACE/FOPEN, ICINTERFACE/FLUSHINPUT, ICINTERFACE/FLUSHOUTPUT,
%   INSTRHELP.
%

%   MP 1-27-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.7.2.6 $  $Date: 2004/01/16 20:02:13 $

% Error checking.
if length(obj)>1
    error('instrument:clrdevice:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

if any(strcmp(obj.type, {'serial', 'gpib-vxi', 'tcpip'}))
    error('instrument:clrdevice:invalidOBJ', 'CLRDEVICE is supported for GPIB, VISA-GPIB, VISA-VXI, VISA-USB and VISA-RSIB objects.');
end

% Call the java clrdevice method.  
try
	clrdevice(igetfield(obj, 'jobject'));
catch
	error('instrument:clrdevice:opfailed', lasterr);
end