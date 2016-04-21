function pixperdata = getPixelsPerData(hThis)

% Copyright 2003 The MathWorks, Inc.

hAxes = get(hThis,'Parent');

xl = get(hAxes,'XLim');
yl = get(hAxes,'YLim');

oldUnits = get(hAxes,'Units');
set(hAxes,'Units','pixels')
pixpos = get(hAxes, 'Position');
set(hAxes,'Units',oldUnits);

pixperdata = [ pixpos(3) / (xl(2) - xl(1)), pixpos(4) / (yl(2)-yl(1))];
