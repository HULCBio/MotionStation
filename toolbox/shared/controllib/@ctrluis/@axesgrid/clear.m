function clear(h)
%CLEAR  Clears wrapper object without destroying axes.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:42 $

h.Axes = [];
h.BackgroundAxes = [];

delete(h)