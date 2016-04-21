%RBBOX  Rubberband box.
%
%   RBBOX initializes and tracks a rubberband box in the current figure. It
%   sets the initial rectangular size of the box to 0, anchors the box at
%   the figure's CurrentPoint, and begins tracking from this point.
%
%   RBBOX(initialRect) specifies the initial location and size of the
%   rubberband box as [x y width height], where x and y define the
%   lower-left corner, and width and height define the size. initialRect is
%   in the units specified by the current figure's Units property, and
%   measured from the lower-left corner of the figure window. The corner of
%   the box closest to the pointer position follows the pointer until RBBOX
%   receives a button-up event.
%
%   RBBOX(initialRect,fixedPoint) specifies the corner of the box that
%   remains fixed. All arguments are in the units specified by the current
%   figure's Units property, and measured from the lower-left corner of the
%   figure window. fixedPoint is a two-element vector, [x y]. The tracking
%   point is the corner diametrically opposite the anchored corner defined
%   by fixedPoint.
%
%   RBBOX(initialRect,fixedPoint,stepSize) specifies how frequently the
%   rubberband box is updated. When the tracking point exceeds stepSize
%   figure units, RBBOX redraws the rubberband box. The default stepsize is
%   1.
%
%   finalRect = RBBOX(...) returns a four-element vector, [x y width
%   height], where x and y are the x and y components of the lower-left
%   corner of the box, and width and height are the dimensions of the box.
%
%   The mouse button must be down when RBBOX is called. RBBOX can be used in
%   a ButtondownFcn, or in an M-file, along with WAITFORBUTTONPRESS, to
%   control dynamic behavior.
%
%   Example:
%
%   figure;
%   pcolor(peaks);
%   k = waitforbuttonpress;
%   point1 = get(gca,'CurrentPoint');    % button down detected
%   finalRect = rbbox;                   % return figure units
%   point2 = get(gca,'CurrentPoint');    % button up detected
%   point1 = point1(1,1:2);              % extract x and y
%   point2 = point2(1,1:2);
%   p1 = min(point1,point2);             % calculate locations
%   offset = abs(point1-point2);         % and dimensions
%   x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
%   y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
%   hold on
%   axis manual
%   plot(x,y,'r','linewidth',5)          % draw box around selected region
%
%   See also WAITFORBUTTONPRESS, DRAGRECT.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.9 $  $Date: 2002/04/15 03:24:49 $
%   Built-in function.
