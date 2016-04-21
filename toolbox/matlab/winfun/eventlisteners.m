function events = eventlisteners(h)
%EVENTLISTENERS Lists all events that are registered.
%   EVENTLISTENERS(H) Lists all events that are registered, 
%   where H is the handle to the COM control. Result is a cell
%   array of events and its registered eventhandlers.
%
%      eventlisteners(h)
%   
%   See also REGISTEREVENT, UNREGISTEREVENT.

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2002/12/03 03:45:03 $

if nargin < 1
    error('Invalid number of inputs');
end
if (isempty(findstr(class(h), 'COM.')))
    error('Input handle is invalid');
end

events = {};
p = findprop(h, 'MMListeners_Events');

if (isempty(p))
    return
end

p.AccessFlags.Publicget = 'on';
        
%dont proceed if no events are registered
 [row,col] = size(h.MMListeners_Events);
 if(row == 0)
    return
 end    

listn = h.MMListeners_Events;

for i=1:row
    events{i, 1} = listn(i).EventType;
    events{i, 2} = listn(i).Callback{2};
end    

p.AccessFlags.Publicget = 'off';
        