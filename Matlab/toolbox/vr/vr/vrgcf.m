function y = vrgcf
%VRGCF Get the current VRFIGURE object.
%   F = VRGCF returns a VRFIGURE object representing the current VR figure.
%   The current figure is the figure that currently has keyboard and mouse
%   focus.
%
%   When no VR figure exists, VRGCBF returns an empty array of VRFIGURE
%   objects.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2003/10/30 18:45:42 $ $Author: batserve $

handle = vrsfunc('GetCurrentFigure');
if handle == 0
  y = vrfigure([]);
else
  y = vrfigure(handle);
end
