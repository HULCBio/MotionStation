function sendMouseEvent(hThis,eventname,hTarget)

% Copyright 2003 The MathWorks, Inc.

% ToDo: Break this method into seperate methods for
% each event type after method class loading performance 
% improves. 

hEvent = handle.EventData(hThis,eventname);
if ~isempty(hEvent)
   schema.prop(hEvent,'Target','handle');
   set(hEvent,'Target',hTarget);
   send(hThis,eventname,hEvent);
end