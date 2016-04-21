function obj = isetfield(obj, field, value)
%ISETFIELD Set device group object internal fields.
%
%   OBJ = ISETFIELD(OBJ, FIELD, VAL) sets the value of OBJ's FIELD 
%   to VAL.
%
%   This function is a helper function for the concatenation and
%   manipulation of device group object arrays. This function should
%   not be used directly by users.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:00:07 $

% Assign the specified field information.
try
    obj.(field) = value;
catch
   error('icgroup:isetfield:invalidFIELD', ['Unable to set the field: ' field]);
end