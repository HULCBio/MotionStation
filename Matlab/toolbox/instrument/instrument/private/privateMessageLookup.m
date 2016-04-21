function msg = privateMessageLookup(ID)
%PRIVATEMESSAGELOOKUP Return a message for device objects.
%
%    PRIVATEMESSAGELOOKUP(MSGID) returns the message string cooresponding to
%    the message ID, MSGID.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/03/30 13:06:29 $

switch ID
case 'instrument:icdevice:invalidSyntax'
    msg = 'A device object is instantiated through the DEVICE constructor.';
    
case 'instrument:icdevice:nojvm'
    msg = 'Instrument class objects require JAVA support.';

case 'instrument:icdevice:toofewargs'
    msg = 'The DRIVER and HWOBJ must be specified.';

case 'instrument:icdevice:invalidType'
    msg = 'HWOBJ must be an interface object.';
  
case 'instrument:icdevice:invalidobj'
    msg = 'HWOBJ must be a valid interface object.';

case 'instrument:icdevice:invalidLength'
    msg = 'HWOBJ must be a 1-by-1 interface object.';
    
case 'instrument:icdevice:invalidDriver'
    msg = 'DRIVER must be a string.';
  
case 'instrument:icdevice:driverNotFound'
    msg = 'DRIVER could not be found. The DRIVER must be on the MATLAB path.';
  
case 'icdevice:connect:tooFewArgs'
    msg = 'Not enough input arguments.';

case 'icdevice:connect:tooManyArgs'
    msg = 'Too many input arguments.';
    
case 'icdevice:connect:invalidOBJ'
    msg = 'OBJ must be a device object.';
    
case 'icdevice:connect:invalidFlag'
    msg = 'Invalid UPDATE specified. UPDATE must be either ''object'' or ''instrument''.';
    
case 'icdevice:connect:invalid'
    msg = 'An object in OBJ could not be opened or was already open.';
    
case 'icdevice:disconnect:invalid'
    msg = 'An object in OBJ could not be closed or is invalid.';
    
case 'icdevice:deviceclear:invalidOBJ'
    msg = 'OBJ must be a 1-by-1 device object.';
    
case 'icdevice:selftest:invalidOBJ'
    msg = 'OBJ must be a 1-by-1 device object.';

case 'icdevice:geterror:invalidOBJ'
    msg = 'OBJ must be a 1-by-1 device object.';
    
case 'icdevice:devicereset:invalidOBJ'
    msg = 'OBJ must be a 1-by-1 device object.';
    
otherwise
    msg = ['Error: ' ID];
end
