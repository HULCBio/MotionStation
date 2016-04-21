function [ymin,ymax,FlatY] = ydataspan(Xdata,Ydata,Xlims)
%YDATASPAN  Computes Y data extent for given X range.

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.2 $ $Date: 2002/04/10 04:43:52 $

toLeft = (Xdata<Xlims(1));
toRight = (Xdata>Xlims(2));
ixL = find(toLeft);   % data points left of Xlims(1)
ixR = find(toRight);  % data points right of Xlims(1)
ixC = find(~toLeft & ~toRight); % data points in range

if isempty(ixC)
   if (isempty(ixL) | isempty(ixR))
      % All data lies left of Xlims(1) or right of Xlims(2): immaterial
      y = 0;
   else
      % Get trace of line segment going through Xlims range
      x1 = Xdata(ixL(end));
      x2 = Xdata(ixR(1));
      t = (Xlims - x1)/(x2-x1);
      % Projection of end points on Y axis
      y = (1-t) * Ydata(ixL(end)) + t * Ydata(ixR(1)); 
   end
else
   % Guard against undersampled data by including points where curve
   % intersects the vertical lines x=Xlims(1) and x=Xlims(2)
   if isempty(ixL)
      yL = [];
   else
      x1 = Xdata(ixL(end));
      x2 = Xdata(ixC(1));
      t = (Xlims(1) - x1)/(x2-x1);
      yL = (1-t) * Ydata(ixL(end)) + t * Ydata(ixC(1));
   end
   if isempty(ixR)
      yR = [];
   else
      x1 = Xdata(ixC(end));
      x2 = Xdata(ixR(1));
      t = (Xlims(2) - x1)/(x2-x1);
      yR = (1-t) * Ydata(ixC(end)) + t * Ydata(ixR(1));
   end
   y = [yL ; Ydata(ixC); yR];  % points defining the Y extent
end

ymin = min(y);
ymax = max(y);
FlatY = (ymax-ymin<=1e3*eps*(abs(ymin)+abs(ymax)));
