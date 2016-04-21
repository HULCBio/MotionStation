function result = isappdata(handle, name)
%ISAPPDATA True if application-defined data exists.
%  ISAPPDATA(H, NAME) returns 1 if application-defined data with
%  the specified NAME exists on the object specified by handle H,
%  and returns 0 otherwise.
%
%  See also SETAPPDATA, GETAPPDATA, RMAPPDATA.

%  Damian T. Packer, May 1998
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.8 $  $Date: 2002/04/10 17:06:17 $

if length(handle) ~= 1, error('H must be a single handle.'); end
result = isfield(get(handle, 'ApplicationData'), name);
