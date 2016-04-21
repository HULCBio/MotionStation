function out = igetfield(obj, field)
%IGETFIELD Get serial port object internal fields.
%
%   VAL = IGETFIELD(OBJ, FIELD) returns the value of object's, OBJ,
%   FIELD to VAL.
%
%   This function is a helper function for the concatenation and
%   manipulation of serial port object arrays. This function should
%   not be used directly by users.
%

%   MP 7-27-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.3 $  $Date: 2004/01/16 20:04:22 $


% Return the specified field information.
try
    out = obj.(field);
catch
   error('MATLAB:serial:igetfield:invalidFIELD', ['Invalid field: ' field]);
end
