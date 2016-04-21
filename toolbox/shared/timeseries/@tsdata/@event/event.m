function h = event(name, time)
%EVENT Event object constructor
%
%   Authors: James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:33:12 $

h = tsdata.event;
if ischar(name)
    h.Name = name;
else
    error('The event name must be specified by the first argument')
end

if isnumeric(time) && length(time)==1
    h.Time = time;
else
    error('Time must be specified as a numeric scalar value')
end