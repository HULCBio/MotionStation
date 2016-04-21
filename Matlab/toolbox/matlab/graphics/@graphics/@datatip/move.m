function move(hThis,dir)
% Move datatip based on direction i.e. 'left', 'right', etc

% Copyright 2002-2003 The MathWorks, Inc.

% Create new data cursor
hNewDataCursor = copy(hThis.DataCursorHandle);

% Update cursor based on direction (should 
% be a static method)
moveDataCursor(hNewDataCursor,hThis.Host,hNewDataCursor,dir); 

% Update datatip based on cursor
updatePositionAndString(hThis,hNewDataCursor);

