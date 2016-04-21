function out = selftest(obj)
%SELFTEST Run the instrument self-test.
%
%   OUT = SELFTEST(OBJ) runs the self-test for the instrument associated  
%   with device object, OBJ and returns the result of the self-test to OUT. 
%   OUT will vary based on the instrument.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.7 $  $Date: 2004/03/05 18:10:12 $

% Error checking.
if (length(obj) > 1)
    errorID = 'icdevice:selftest:invalidOBJ';
    error(errorID, instrgate('privateMessageLookup', errorID));
end

% Call selftest on the java object.
try
    jobj = igetfield(obj, 'jobject');    
    out = char(selftest(jobj));
catch
    error('icdevice:selftest:opfailed', [lasterr ' Use MIDEDIT to update the driver if appropriate.']);
end   

try
    out = logical(str2double(out));
catch
end