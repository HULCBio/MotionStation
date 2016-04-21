function setOrientation(this, orient)
%SETORIENTATION Set baseline orientation
%  SETORIENTATION(H,DIR) sets the orientation of baseline H to
%  DIR, either 'x' or 'y'. Default is 'x'.

% Copyright 2003 The MathWorks, Inc.

ax = ancestor(this,'axes');
if orient == 'x'
  h.xdata = get(ax,'XLim');
  h.ydata = [this.basevalue this.basevalue];
  h.orientation = 'X';
else
  h.ydata = get(ax,'YLim');
  h.xdata = [this.basevalue this.basevalue];
  h.orientation = 'Y';
end
