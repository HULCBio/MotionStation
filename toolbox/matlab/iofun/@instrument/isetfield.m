function obj = isetfield(obj, field, value)
%ISETFIELD Set instrument object internal fields.
%
%   OBJ = ISETFIELD(OBJ, FIELD, VAL) sets the value of OBJ's FIELD 
%   to VAL.
%
%   This function is a helper function for the concatenation and
%   manipulation of instrument object arrays. This function should
%   not be used directly by users.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2004/01/16 20:04:00 $

% Assign the specified field information.
switch field
case 'store'
   obj.store = value;
otherwise
   error('MATLAB:instrument:isetfield:invalidFIELD',['Unable to set the field: ' field]);
end
