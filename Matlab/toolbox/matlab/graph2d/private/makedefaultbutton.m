function border = makedefaultbutton(uic)
%ADDBUTTONBORDER   Plot Editor helper function

%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Date: 2002/04/15 04:05:37 $  $Revision: 1.7 $

parent = get(uic,'Parent');
oldUnits = get(uic,'Units');
color = get(uic,'ForegroundColor');
set(uic,'Units','pixels');
pos = get(uic,'Position');
border = axes('Units','pixels','Position',pos,...
        'Parent',parent,...
        'XTick',[],'YTick',[],'ZTick',[],...
        'Color','none',...
        'XColor', color,...
        'YColor', color,...        
        'Box','on');
set(uic,'Position',pos+[1 1 -2 -2]);
set(uic,'Units',oldUnits);
