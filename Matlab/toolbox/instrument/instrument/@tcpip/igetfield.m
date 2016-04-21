function out = igetfield(obj, field)
%IGETFIELD Get instrument object internal fields.
%
%   VAL = IGETFIELD(OBJ, FIELD) returns the value of object's, OBJ,
%   FIELD to VAL.
%
%   This function is a helper function for the concatenation and
%   manipulation of instrument object arrays. This function should
%   not be used directly by users.
%

%   MP 7-27-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.3 $  $Date: 2004/01/16 20:01:47 $


% Return the specified field information.
try
    out = obj.(field);
catch
   error('instrument:igetfield:invalidFIELD', ['Invalid field: ' field]);
end
