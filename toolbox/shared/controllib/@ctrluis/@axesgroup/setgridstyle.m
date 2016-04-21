function setgridstyle(this,Prop,Value)
%SETGRIDCOLOR  Updates style of grid lines and labels.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:18 $

GH = this.GridLines(ishandle(this.GridLines));
switch Prop
case 'Color'
    set(findobj(GH,'Type','line'),'Color',Value)
    set(findobj(GH,'Type','text'),'Color',0.5*Value)
end