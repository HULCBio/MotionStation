function out = geterror(obj)
%GETERROR Check and return error message from instrument.
%
%   MSG = GETERROR(OBJ) checks the instrument associated with device object,
%   OBJ, for an error message and returns to MSG. The interpretation of MSG
%   will vary based on the instrument.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/03/05 18:10:10 $

% Error checking.
if (length(obj) > 1)
    errorID = 'icdevice:geterror:invalidOBJ';
    error(errorID, instrgate('privateMessageLookup', errorID));
end

% Call getError on the java object.
try
    jobj = igetfield(obj, 'jobject');    
    out = char(getError(jobj));
catch
    error('icdevice:geterror:opfailed', [lasterr ' Use MIDEDIT to update the driver if appropriate.']);
end   
