function out = daqgetfield(obj, field)
%DAQGETFIELD Set and get data acquisition internal fields.
%
%    VAL = DAQGETFIELD(OBJ, FIELD) returns the value of object's, OBJ,
%    FIELD to VAL.
%
%    This function is a helper function for the concatenation and 
%    manipulation of device object arrays.
%

%    MP 12-22-98   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:41:37 $

% Return the specified field information.
switch field
case 'handle'
   out = obj.handle;
case 'info'
   out = obj.info;
case 'version'
   out = obj.version;
case 'daqdevice'
   out = obj.daqdevice;
otherwise
   error('daq:daqgetfield:invalidfield', 'Invalid field: %s', field);
end
