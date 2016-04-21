function paste(this,position)
%paste paste this line
%
%  paste(POSITION) moves the center of the line to POSITION, preserving the
%  slope, and makes the line visible.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:38 $

xdata = get(this,'XData');
ydata = get(this,'YData');
linecenter = [diff(xdata)/2 + xdata(1),diff(ydata)/2 + ydata(1)];
newXData = xdata + position(1) - linecenter(1);
newYData = ydata + position(2) - linecenter(2);
set(this,...
    'LineCenter',linecenter,...
    'Visible','on',...
    'XData',newXData,...
    'YData',newYData);

if this.IsArrow
  MapGraphics.ArrowHead(this);
end
