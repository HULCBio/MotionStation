function render(hThis)
%CURSORBAR/RENDER

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar/render.m start render')


oldShowHiddenHandles= get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

hAxes = get(hThis,'Parent');
kids = get(hAxes,'Children');
kids(handle(kids) == handle(hThis)) = [];
temp = [double(hThis); double(kids)];
set(hAxes,'Children',temp);

set(0,'ShowHiddenHandles',oldShowHiddenHandles);

% debug(hThis,'@cursorbar/render.m end render')