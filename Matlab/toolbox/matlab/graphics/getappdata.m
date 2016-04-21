function value = getappdata(h, name)
%GETAPPDATA Get value of application-defined data.
%  VALUE = GETAPPDATA(H, NAME) gets the value of the
%  application-defined data with name specified by NAME in the
%  object with handle H.  If the application-defined data does
%  not exist, an empty matrix will be returned in VALUE.
%
%  VALUES = GETAPPDATA(H) returns all application-defined data
%  for the object with handle H.
%
%  See also SETAPPDATA, RMAPPDATA, ISAPPDATA.

%  Copyright 1984-2003 The MathWorks, Inc.
%  $Revision: 1.11.4.2 $  $Date: 2004/04/10 23:28:42 $


error(nargchk(1, 2, nargin));

if length(h) ~= 1
   error('H must be a single handle.');
end

value = get(h, 'ApplicationData');
if nargin == 2
    la = lasterr;
    try
        value = value.(name);
    catch
        value = [];
        lasterr(la)
    end
end

