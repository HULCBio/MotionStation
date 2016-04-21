function s = getVisibleAxisSize(this,units)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:14:55 $

% Lower Right
t = text('Parent',this.Axis,'Units','normalized','Position',[0 0 0],...
         'String','ignore','Visible','off');
set(t,'Units',units);
p = get(t,'Position');
px(1) = p(1);
py(1) = p(2);
delete(t);

% Upper Left
t = text('Parent',this.Axis,'Units','normalized','Position',[1 1 0],...
         'String','ignore','Visible','off');
set(t,'Units',units);
p = get(t,'Position');
px(2) = p(1);
py(2) = p(2);
delete(t);

s = [diff(px) diff(py)];



