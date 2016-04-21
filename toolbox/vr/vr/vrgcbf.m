function y = vrgcbf
%VRGCBF Get the current callback VRFIGURE object.
%   F = VRGCBF returns a VRFIGURE object representing the VR figure
%   that contains the callback being currently executed.
%
%   When no VR figure callbacks are executing, VRGCBF returns
%   an empty array of VRFIGURE objects.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/06 01:11:16 $ $Author: batserve $

handle = vrsfunc('GetCallbackFigure');
if handle == 0
  y = vrfigure([]);
else
  y = vrfigure(handle);
end
