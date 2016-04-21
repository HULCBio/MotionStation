function ax = allaxes(h)
%ALLAXES  Collects all HG axes (private method)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:39 $

ax = [h.Axes2d(:);h.BackgroundAxes];