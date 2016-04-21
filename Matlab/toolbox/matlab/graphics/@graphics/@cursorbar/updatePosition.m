function updatePosition(hThis,hNewDataCursor)
% Update cursorbar positionbased on data cursor

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\updatePosition start updatePosition')

pos = hNewDataCursor.Position;
hAxes = ancestor(hThis,'axes');
ok = false;

% debug(hThis,'@cursorbar\updatePosition get axes limits')

% See if the cursor position is empty or outside the
% axis limits

% debug(hThis,'@cursorbar\updatePosition get axes x limits')
xlm = get(hAxes,'xlim');
% debug(hThis,'@cursorbar\updatePosition get axes y limits')
ylm = get(hAxes,'ylim');
% debug(hThis,'@cursorbar\updatePosition get axes z limits')
zlm = get(hAxes,'zlim');

% debug(hThis,['@cursorbar\updatePosition pos = ' num2str(pos)])
if ~isempty(pos) & ...
        (pos(1) >= min(xlm)) & (pos(1) <= max(xlm)) & ...
        (pos(2) >= min(ylm)) & (pos(2) <= max(ylm))
    if length(pos) > 2
        if pos(3) >= min(zlm) & pos(3) <= max(zlm)
            ok =true;
        end
    else
        ok = true;
    end
end

% Update DataCursorHandle and Position
if ok
    hThis.DataCursorHandle = hNewDataCursor;
    hThis.Position = pos;
end

% debug(hThis,'@cursorbar\updatePosition end updatePosition')