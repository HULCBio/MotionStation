function unregisterevent(h, userInput)
%UNREGISTEREVENT Unregister events for a specified control at runtime.
%   UNREGISTEREVENT(H, USERINPUT) unregisters events, where H is
%   the handle to the COM control and USERINPUT is either a
%   char array or a cell array of strings.
%
%   When USERINPUT is a char array all events are removed from the
%    specified file.
%      unregisterevent(h, 'sampev')
%        - Removes all events of h from sampev.m file
%
%   When USERINPUT is a cell array of strings, it must contain valid 
%   event names and eventhandlers that are to be unregistered. For example,
%
%      unregisterevent(h, {'Click' 'sampev'; 'dblclick' 'sampev})
%   
%   See also REGISTEREVENT, EVENTLISTENERS.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2004/04/19 01:13:56 $
if nargin < 2
    error('Invalid number of inputs');
end

if (~strncmp(class(h),'COM.',4))
    error('Invalid input handle');
end

if (iscell(userInput))
    [m,n] = size(userInput);
    for i=1:m
        eventname =userInput{i, 1};
        eventhandler = userInput{i, 2};
        removeevent(h, eventname, eventhandler);
    end
elseif (ischar(userInput) || isa(userInput, 'function_handle'))
    if (isempty(userInput))
        error('eventhandler cannot be empty');
    end
 
    [m,n] = size(h.classhandle.Events);
    for i=1:m
        eventname = h.classhandle.Event(i).Name;
        removeevent(h, eventname, userInput);
    end
else
    error('Event name must be either a eventhandler name or a cell array of strings.');
end    


