function value = getuprop(handle, name)
%GETUPROP Get value of user-defined property.
%  VALUE = GETUPROP(H, NAME) gets the value of the
%  user-defined property with name specified by NAME in the
%  object with handle H.  If the user-defined property does
%  not exist, an empty matrix will be returned in VALUE.
%
%  VALUES = GETUPROP(H) returns all user-defined properties
%  for the object with handle H.
%
%  This function is obsolete, use GETAPPDATA instead.
%
%  See also SETAPPDATA, RMAPPDATA, ISAPPDATA.

%  Steven L. Eddins, October 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.18 $  $Date: 2002/04/15 03:24:29 $

error(nargchk(1,2,nargin));

if nargin == 1
    value = getappdata(handle);
elseif nargin == 2
    value = getappdata(handle, name);
end
