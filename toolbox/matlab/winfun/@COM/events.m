function varargout = events(obj)
%EVENTS Return list of events the COM object can trigger.
%   S = EVENTS(OBJ) returns structure array S containing all events, both
%   registered and unregistered, known to the object, and the function
%   prototype used when calling the event handler routine. For each array
%   element, the structure field is the event name and the contents of that
%   field is the function prototype for that event's handler.
%
%   Equivalent syntax is
%      S = OBJ.EVENTS
%
%   Example:
%       h = actxserver('Excel.Application');
%       s = h.events;
%
%   See also WINFUN/ISEVENT, WINFUN/EVENTLISTENERS, WINFUN/REGISTEREVENT, 
%   WINFUN/UNREGISTEREVENT, WINFUN/UNREGISTERALLEVENTS.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/01/02 18:06:02 $
