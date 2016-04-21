function setuprop(h, name, value)
%SETUPROP Set user-defined property.
%  SETUPROP(H, NAME, VALUE) sets a user-defined property for
%  the object with handle H.  The user-defined property,
%  which is created if it does not already exist, is
%  assigned a NAME and a VALUE.  VALUE may be anything.
%
%  This function is obsolete, use SETAPPDATA instead.
%
%  See also GETAPPDATA, RMAPPDATA, ISAPPDATA.

%  Steven L. Eddins, October 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.20 $  $Date: 2002/04/15 03:25:49 $
%  Built-in function.

setappdata(h, name, value);
