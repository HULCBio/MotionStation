function keypressfcn(hZoom)

% Copyright 2002 The MathWorks, Inc.

if strcmp(hZoom.Debug,'on')
    disp('keypressfcn')
end

hFigure = get(hZoom,'FigureHandle');
hAxes = get(hFigure,'CurrentAxes');

% Bail out if no handle to axes
if ~ishandle(hAxes), return; end

ch = get(hFigure,'CurrentCharacter');

if isempty(ch), return; end

switch(uint16(ch))
   case 28 %ascii left arrow
     ;
   case 29 %ascii right arrow
     ;
   case 30 %ascii up arrow
     applyzoomfactor(hZoom,hAxes,2);
   case 31 %ascii down arrow
     applyzoomfactor(hZoom,hAxes,.9);
end


