%DRAGRECT Drag XOR rectangles with mouse.
%   DRAGRECT(RECTS) allows the rectangles specified in the
%   N-by-4 matrix RECTS to be dragged with the mouse while a mouse
%   button is down.  Rectangles can be dragged anywhere on the
%   screen.
%   DRAGRECT(RECTS, STEPSIZE) moves the rectangles only in increments
%   of STEPSIZE.  The lower-left corner of the first rectangle
%   is constrained to the grid of size STEPSIZE starting at the
%   lower-left corner of the figure, and all other rectangles
%   maintain their original offset from the first rectangle.
%   RECTS2=DRAGRECT(...) returns the final positions of the rectangles
%   specified in RECTS when the mouse button is released.
%
%   Each row of RECTS must contain the initial rectangle position
%   as [left bottom width height].  DRAGRECT returns the final
%   position of the rectangles.  If the drag ends over a
%   figure window, the positions of the rectangles  are
%   returned in that figure's coordinate system.  If the drag ends
%   over a part of the screen not contained within a figure window,
%   the rectangles are returned in the coordinate system of the
%   figure over which the drag began.  DRAGRECT returns immediately
%   if a mouse button is not down.
%   
%
%   See also RBBOX.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/15 03:26:13 $
%   Built-in function.
