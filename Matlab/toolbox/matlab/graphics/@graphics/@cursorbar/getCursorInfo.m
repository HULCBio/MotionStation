function info = getCursorInfo(hThis)
%GETCURSORINFO get datacursor info from cursorbar

% Copyright 2003 The MathWorks, Inc.

info = struct;

hDC = hThis.DataCursorHandle;

info.Position = hDC.Position;
