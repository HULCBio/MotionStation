function move(hThis,dir)
% MOVE 

% Copyright 2003 The MathWorks, Inc.


debug(hThis,'@cursorbar/move start move')

% % Create new data cursor
% hNewDataCursor = copy(hThis.DataCursorHandle);

% Update cursor based on direction (should 
% be a static method)
moveDataCursor(hThis.DataCursorHandle,hThis,hThis.DataCursorHandle,dir); 

pos = get(hThis.DataCursorHandle,'Position');
set(hThis,'Position',pos);

% throw event indicating that the cursorbar was updated
hEvent = handle.EventData(hThis,'UpdateCursorBar');
send(hThis,'UpdateCursorBar',hEvent);

debug(hThis,'@cursorbar/move end move')