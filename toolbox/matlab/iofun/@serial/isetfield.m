function obj = isetfield(obj, field, value)
%ISETFIELD Set serial port object internal fields.
%
%   OBJ = ISETFIELD(OBJ, FIELD, VAL) sets the value of OBJ's FIELD 
%   to VAL.
%
%   This function is a helper function for the concatenation and
%   manipulation of serial port object arrays. This function should
%   not be used directly by users.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.3 $  $Date: 2004/01/16 20:04:28 $

% Assign the specified field information.
try
    obj.(field) = value;
catch
   error('MATLAB:serial:isetfield:invalidFIELD', ['Unable to set the field: ' field]);
end


