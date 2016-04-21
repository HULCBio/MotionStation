function [ret] = dosupport(hThis,hTarget)

% Copyright 2003 The MathWorks, Inc.

% axes or axes children
ret = ~isempty(ancestor(hTarget,'hg.axes'));
