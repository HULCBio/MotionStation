function updateDataCursor(hThis,hNewDataCursor,target)
%UPDATEDATACURSOR

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\updateDataCursor.m start updateDataCursor')

hAxes = get(hThis,'Parent');
cp = get(hAxes,'CurrentPoint');
pos = [cp(1,1) cp(1,2) 0];

if isTargetAxes(hThis)
    % axes, ignore interpolation, just use the axes' CurrentPoint
%     debug(hThis,'@cursorbar\updateDataCursor.m axes ')

    set(hNewDataCursor,'Position',pos);
else
    
%     debug(hThis,'@cursorbar\updateDataCursor.m line ')

    [x,y] = closestvertex(hThis,pos);
    set(hNewDataCursor,'Position',[x y 0]);
end


% debug(hThis,'@cursorbar\updateDataCursor.m end updateDataCursor')