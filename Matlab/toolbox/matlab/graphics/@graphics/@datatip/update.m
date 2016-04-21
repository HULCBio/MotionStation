function update(hThis,target)
% Update datatip position and string based on target

% Copyright 2002-2003 The MathWorks, Inc.

if nargin<2
    hAxes = get(hThis,'HostAxes');
    target = get(hAxes,'CurrentPoint');
end

% Create new data cursor if necessary
if ishandle(hThis.DataCursorHandle)
    hNewDataCursor = get(hThis,'DataCursorHandle');
else
    hNewDataCursor = graphics.datacursor;
end

% Update cursor based on target (should
% be a static method)
updateDataCursor(hNewDataCursor,hThis.Host,hNewDataCursor,target); 

% Update datatip based on cursor
updatePositionAndString(hThis,hNewDataCursor);
