function devicereset(obj)
%DEVICERESET Reset instrument.
% 
%   DEVICERESET(OBJ) resets the instrument associated with device
%   object, OBJ. 
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/03/05 18:10:08 $

% Error checking.
if (length(obj) > 1)
    errorID = 'icdevice:devicereset:invalidOBJ';
    error(errorID, instrgate('privateMessageLookup', errorID));
end

% Call hwreset on the java object.
try
    jobj = igetfield(obj, 'jobject');    
    hwreset(jobj);
catch
    error('icdevice:devicereset:opfailed', [lasterr ' Use MIDEDIT to update the driver if appropriate.']);
end   
