function sendUpdateDatatipEvent(hThis,hDatatip)

% Copyright 2002-2003 The MathWorks, Inc.

if hThis.Debug
  disp('sendUpdateDatatipEvent')
end

% Create event object
hEvent = handle.EventData(hThis,'UpdateDatatip');
schema.prop(hEvent,'Datatip','handle');

if nargin < 2,
    set(hEvent,'Datatip',hThis.CurrentDatatip);
else
    set(hEvent,'Datatip',hDatatip);
end

% Send event
send(hThis,'UpdateDatatip',hEvent);