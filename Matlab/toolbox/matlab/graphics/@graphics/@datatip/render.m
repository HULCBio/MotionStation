function render(hThis)
% Move the marker and textbox to the top of the 
% axes child order so that it always renders on top.

% Copyright 2003 The MathWorks, Inc.

hAxes = getaxes(hThis);
kids = handle(get(hAxes,'children'));
kids(kids == hThis) = [];
temp = [double(hThis); double(kids)];

%hMarker = hThis.MarkerHandle;
hText = hThis.TextBoxHandle;
%temp = [double(hText),double(hMarker),double(kids')];
set(hAxes,'children',temp);

% Force text box to appear on top in zbuffer by
% leaving the units property to 'pixels'
set(hText,'units','pixels');