function registerevent(h, userInput)
%REGISTEREVENT Registers events for a specified control at runtime.
%   REGISTEREVENT(H, USERINPUT) registers events, where H is
%   the handle to the COM control and USERINPUT is either a
%   1xn char array or an mx2 cell array of strings. 
%
%   When USERINPUT is a char array it specifies the event handler
%   for all events that can be registered by the control. For example,
%
%      registerevent(h, 'allevents')
%
%   When USERINPUT is a cell array of strings, an event name 
%   and event handler pair specify the event to be registered. 
%   For example, 
%
%      registerevent(h, {'Click' 'sampev'; 'Mousedown' 'sampev'})
%   
%   See also UNREGISTEREVENT, EVENTLISTNERS, ACTXCONTROL.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/19 01:13:55 $


% first check number of arguments
if nargin < 2
    error('Invalid number of inputs');
end

if (~strncmp(class(h),'COM.',4))
    error('Invalid input handle');
end

%check to see if input is in cell array form
if (iscell(userInput))
    [m,n] = size(userInput);
    
    eventexist = cell(m, 1);
    newevent = cell(m, 1);
            
    for i=1:m
        event = userInput{i,1};
         %check to see if event name is valid
        [eventexist{i}, newevent{i}] = checkeventname(h, event);
        
        if (eventexist{i} ~= 1)
            str = sprintf('Error registering events. ''%s'' is not a valid event name.', event);
            error(str)
        end   
    end  
    
    % no error proceed with registering
    for i=1:m
        %we need to get eventname because input event ids are converted
        %here
        event = newevent{i};
        eventhandler = userInput{i,2};
     
        %add event to the list
        addevent(h, event, eventhandler);            
    end    
else
    if (isempty(userInput))
        error('eventhandler cannot be empty');
    elseif (~ischar(userInput) && ~isa(userInput, 'function_handle'))
        error('eventhandler must be a string or a function handle');    
    end
         
    %register all events to userinput
    [m,n] = size(h.classhandle.Events);
     
    for i=1:m
        event = h.classhandle.Event(i).Name;
        addevent(h, event, userInput);
    end  
end    

function addevent(h, eventname, eventhandler)

%find out if the property is already created for events
p= h.findprop('MMListeners_Events');

if (isempty(p))
    p=schema.prop(h, 'MMListeners_Events', 'handle vector');
end

%turn the property on so that we can set and get
p.AccessFlags.Publicget = 'on';
p.AccessFlags.Publicset = 'on';

[m,n] = size(h.MMListeners_Events);

%we need to get the list from listener if it already exists
if(m > 0)
    list = h.MMListeners_Events;

    [row, col] = size(list);

    for i=1:row
        tempevent = list(i).EventType;
        tempcallback = list(i).Callback(2);

        if (strcmpi(eventname, tempevent))
            if (isa(eventhandler, 'function_handle') && isequal(eventhandler, tempcallback{1})) || ...
                    (ischar(eventhandler) && strcmpi(eventhandler, tempcallback))

                return;
            end
        end
    end
end

%new event/handler pair, so add it to the list
list(m+1) = handle.listener(h, eventname, {@comeventcallback, eventhandler});
set(h, 'MMListeners_Events', list);

%hide the event listener property from the user
p.AccessFlags.Publicget = 'off';
p.AccessFlags.Publicset = 'off';
p.AccessFlags.Serialize = 'off';


    