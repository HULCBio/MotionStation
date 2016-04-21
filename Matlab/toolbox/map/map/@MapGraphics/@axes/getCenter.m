function center = getCenter(this)
%GETCENTER Get center of axis
%
%   CENTER = GETCENTER returns the coordinates of the center of the map in map
%   units. CENTER is a 2 element array [X Y], the x and y coordinates of the
%   center of the axes.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:53 $

center = [sum(this.XLim) sum(this.YLim)]/2;
