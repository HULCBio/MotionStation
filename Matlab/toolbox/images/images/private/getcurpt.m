function [x,y] = getcurpt(axHandle)
%GETCURPT Get current point.
%   [X,Y] = GETCURPT(AXHANDLE) gets the x- and y-coordinates of
%   the current point of AXHANDLE.  GETCURPT compensates these
%   coordinates for the fact that get(gca,'CurrentPoint') returns
%   the data-space coordinates of the idealized left edge of the
%   screen pixel that the user clicked on.  For IPT functions, we
%   want the coordinates of the idealized center of the screen
%   pixel that the user clicked on.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.9.4.1 $  $Date: 2003/01/26 05:59:31 $

pt = get(axHandle, 'CurrentPoint');
x = pt(1,1);
y = pt(1,2);

