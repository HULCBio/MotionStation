function update(hThis,evd,varargin)
%UPDATE
% Update cursorbar position and string

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\update.m : start update');

movecb = true;

if nargin == 3 && strcmp(varargin{1},'-nomove')
    movecb = false;
end
    

% Create new data cursor
if ishandle(hThis.DataCursorHandle)
%     debug(hThis,'@cursorbar\update.m : copy datacursor');
    hNewDataCursor = copy(hThis.DataCursorHandle);
else
%     debug(hThis,'@cursorbar\update.m : create new datacursor');
    hNewDataCursor = graphics.datacursor;
end

% Update cursor based on target (should
% be a static method)
if movecb
    updateDataCursor(hThis,hNewDataCursor); 
end
    
% Update cursorbar based on cursor
updatePosition(hThis,hNewDataCursor);

updateMarkers(hThis);

% send event indicating that the cursorbar was updated
hEvent = handle.EventData(hThis,'UpdateCursorBar');
send(hThis,'UpdateCursorBar',hEvent);

% move cursorbar to top
render(hThis);

% debug(hThis,'@cursorbar\update.m end update');