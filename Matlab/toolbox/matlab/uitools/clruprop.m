function clruprop(handle, name)
%CLRUPROP Clear user-defined property.
%  CLRUPROP(H, NAME) clears the user-defined property NAME,
%  if it exists, from the object specified by handle H.
%
%  This function is obsolete, use RMAPPDATA instead.
%
%  See also SETAPPDATA, GETAPPDATA, RMAPPDATA, ISAPPDATA.

%  Steven L. Eddins, October 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.16 $  $Date: 2002/04/15 03:25:59 $

if (~ishandle(handle))
  error('H is not a valid handle.');
end

% for backwards compatibility, it is not an error to specify a
% userprop that doesn't exist
if isappdata(handle, name)
  rmappdata(handle, name);
end
  

