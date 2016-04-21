%AXES   Create axes in arbitrary positions.
%   AXES('position', RECT) opens up an axis at the specified location
%   and returns a handle to it.
%   RECT = [left, bottom, width, height] specifies the location and
%   size of the side of the axis box, relative to the lower-left
%   corner of the Figure window, in normalized units where (0,0)
%   is the lower-left corner and (1.0,1.0) is the upper-right.
%
%   AXES, by itself, creates the default full-window axis and returns
%   a handle to it.
%
%   AXES(H) makes the axis with handle H current.
%
%   Execute GET(H) to see a list of axes object properties and
%   their current values. Execute SET(H) to see a list of axes
%   object properties and legal property values.
%
%   See also SUBPLOT, AXIS, FIGURE, GCA, CLA.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/10 17:06:29 $
%   Built-in function.
