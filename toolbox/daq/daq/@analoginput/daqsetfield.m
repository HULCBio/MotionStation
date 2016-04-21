function obj = daqsetfield(obj, field, value)
%DAQSETFIELD Set and get data acquisition internal fields.
%
%    OBJ = DAQSETFIELD(OBJ, FIELD, VAL) sets the value of OBJ's FIELD to VAL.
%
%    This function is a helper function for the concatenation and manipulation
%    of device object arrays.
%

%    MP 12-22-98   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:39:28 $

% Assign the specified field information.
switch field
case 'handle'
   obj.handle = value;
case 'info'
   obj.info = value;
case 'version'
   obj.version = value;
otherwise
   error('daq:daqsetfield:invalidfield', 'Unable to set the field: %s', field);
end
