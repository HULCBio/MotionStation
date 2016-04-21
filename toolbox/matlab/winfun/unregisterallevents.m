function unregisterallevents(h)
%UNREGISTERALLEVENTS Unregister all events for a specified control at runtime.
%   UNREGISTERALLEVENTS(H) unregisters all events from a control, where H is
%   the handle to the COM control. 
%
%      unregisterallevents(h)
%   
%   See also REGISTEREVENT, UNREGISTEREVENT, EVENTLISTENERS.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/15 00:07:03 $

if (~strncmp(class(h),'COM.',4))
    error('Invalid input handle');
end

events = eventlisteners(h);

if (isempty(events))
    error('No events to unregister')
end    

p = findprop(h, 'MMListeners_Events');
if (isempty(p))
    return;
end

[m,n] = size(events);

for i = 1:m
    eventname = events{i, 1};
    eventhandler = events{i, 2};
    removeevent(h, eventname, eventhandler);
end    

