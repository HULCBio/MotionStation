function ax = initializeAxis(this,map,visibility)
%INITIALIZEAXIS Initialize axis to veiw the map.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:57:02 $

ax = MapGraphics.axes('Parent',this.Figure);
ax.addModel(map);

set(ax,'Units','pixels','Position',getAxisPosition(this.Figure),...
       'XTick',[],'YTick',[],'XColor','white','YColor','white',...
       'Visible',visibility);

set(ax,'Units','normalized');

function axisPosition = getAxisPosition(fig)
oldunits = get(fig,'Units');
set(fig,'Units','pixels');
p = get(fig,'Position');
set(fig,'Units',oldunits);

leftMargin = 10;
bottomMargin = 65;
topMargin = 10;
rightMargin = 10;
axisPosition = [leftMargin,bottomMargin,p(3) - leftMargin - rightMargin,p(4) - bottomMargin - topMargin];
